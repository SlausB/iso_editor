///@cond
package blisc.core
{
	CONFIG::stage3d
	{
		import com.adobe.utils.AGALMiniAssembler;
		import flash.display.Stage3D;
		import flash.display3D.Context3D;
		import flash.display3D.Context3DProgramType;
		import flash.display3D.Context3DRenderMode;
		import flash.display3D.IndexBuffer3D;
		import flash.display3D.Program3D;
		import flash.display3D.VertexBuffer3D;
		import flash.geom.Matrix3D;
		import flash.utils.ByteArray;
	}
	
	import flash.display.Stage;
	
	CONFIG::stage3d == false
	{
		import flash.events.Event;
		import flash.events.TimerEvent;
		import flash.utils.Timer;
	}
	
	///@endcond
	
	
	/** Allocates all needed resources as soon as possible. Can be used within multiple Blisc instances.*/
	public class BliscBatch
	{
		CONFIG::stage3d
		{
			public var _context3D : Context3D;
			public var _stage : Stage;
			
			/** Temporary AGAL assembler to avoid allocation */
			public static const _tempAssembler : AGALMiniAssembler = new AGALMiniAssembler;
			/** Vertex shader program AGAL bytecode */
			public static var _vertexProgram : ByteArray;
			/** Fragment shader program AGAL bytecode */
			public static var _fragmentProgram : ByteArray;
			/** Default program.*/
			public static var _program : Program3D;
			
			public var _buffer : VertexBuffer3D;
			
			public var _onCreated : Function;
			
			public var _mvp : Matrix3D = new Matrix3D;
			public var _viewMatrix : Matrix3D = new Matrix3D;
			public var _orthoProjection : Matrix3D = new Matrix3D;
			public var _orthoData : Vector.< Number > = new Vector.< Number >( 16, true );
			
			public static var _vertexBuffer : VertexBuffer3D = null;
			public static var _indexBuffer : IndexBuffer3D = null;
		}
		
		
		public function BliscBatch(
			onCreated : Function = null,
			stage : Stage = null )
		{
			if ( CONFIG::stage3d )
			{
				var vertexCode : String = 
					"m44 op, va0, vc0\n" + 
					"mov v0, va1"
				;
				_tempAssembler.assemble(
					Context3DProgramType.VERTEX,
					vertexCode
				);
				_vertexProgram = _tempAssembler.agalcode;
				
				var fragmentCode : String =
					"tex ft0, v0, fs0 <2d,clamp,linear,mipnone>\n" + //sample texture
					"mov oc, ft0"
				;
				_tempAssembler.assemble(
					Context3DProgramType.FRAGMENT,
					fragmentCode
				);
				_fragmentProgram = _tempAssembler.agalcode;
				
				_stage = stage;
				
				_onCreated = onCreated;
				
				var stage3D : Stage3D = stage.stage3Ds[ 0 ];
				stage3D.addEventListener( Event.CONTEXT3D_CREATE, onContextCreated );
				stage3D.requestContext3D( Context3DRenderMode.AUTO );
			}
			else
			{
				if ( onCreated != null )
				{
					//through timer to allow caller use returning value (constructed one):
					var timer : Timer = new Timer( 1, 1 );
					timer.addEventListener( TimerEvent.TIMER_COMPLETE, function( ... args ) : void
					{
						onCreated();
					} );
					timer.start();
				}
			}
		}
		
		CONFIG::stage3d
		{
			protected function onContextCreated( ev : Event ) : void
			{
				// Setup context
				var stage3D : Stage3D = _stage.stage3Ds[ 0 ];
				stage3D.removeEventListener( Event.CONTEXT3D_CREATE, onContextCreated );
				_context3D = stage3D.context3D;
				_context3D.configureBackBuffer(
					_stage.stageWidth,
					_stage.stageHeight,
					0,
					//on Android from HTC can be run only with == false:
					false
				);
				_context3D.enableErrorChecking = true;
				
				_buffer = _context3D.createVertexBuffer( 4, 4 ); //x, y, u, v
				//CCW ordering; first point is NW; uv coordinates upside-down
				_buffer.uploadFromVector( Vector.< Number >
				( [
					-1.0, 1.0, 0.0, 1.0,
					-1.0,-1.0, 0.0, 0.0,
					 1.0,-1.0, 1.0, 0.0,
					 1.0, 1.0, 1.0, 1.0
				] ), 0, 4 );
				
				//create the shader program:
				_program = _context3D.createProgram();
				_program.upload( _vertexProgram, _fragmentProgram );
				
				if ( _indexBuffer == null )
				{
					// Create the positions and texture coordinates vertex buffer
					_vertexBuffer = _context3D.createVertexBuffer( 4, 5 );
					_vertexBuffer.uploadFromVector(
						new < Number >[
							// X,  Y,  Z, U, V
							-1,   -1, 0, 0, 1,
							-1,    1, 0, 0, 0,
							 1,    1, 0, 1, 0,
							 1,   -1, 0, 1, 1
						], 0, 4
					);
					
					// Create the triangles index buffer
					_indexBuffer = _context3D.createIndexBuffer( 6 );
					_indexBuffer.uploadFromVector(
						new < uint >[
							0, 1, 2,
							0, 2, 3
						], 0, 6
					);
				}
				
				if ( _onCreated != null )
				{
					_onCreated();
				}
			}
			
			public static function ApplyOrthoProjection( to : Vector.< Number >, w : Number, h : Number, n : Number, f : Number ) : void
			{
				//doing the same as:
				/* Vector< Number > = [
					2/w, 0  ,       0,        0,
					0  , 2/h,       0,        0,
					0  , 0  , 1/(f-n), -n/(f-n),
					0  , 0  ,       0,        1
				] */
				to[ 0 ] = 2 / w;
				to[ 5 ] = 2 / h;
				to[ 10 ] = 1 / ( f - n );
				to[ 11 ] = - n / ( f - n );
				to[ 15 ] = 1;
			}
		}
		
	}

}



