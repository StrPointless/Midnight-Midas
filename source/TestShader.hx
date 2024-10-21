import flixel.system.FlxAssets.FlxShader;

class TestShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main

    uniform float brightness;
    uniform float contrast;
    uniform float saturation;
    
    mat4 brightnessMatrix( float brightness )
    {
        return mat4( 1, 0, 0, 0,
                     0, 1, 0, 0,
                     0, 0, 1, 0,
                     brightness, brightness, brightness, 1 );
    }
    
    mat4 contrastMatrix( float contrast )
    {
        float t = ( 1.0 - contrast ) / 2.0;
        
        return mat4( contrast, 0, 0, 0,
                     0, contrast, 0, 0,
                     0, 0, contrast, 0,
                     t, t, t, 1 );
    
    }
    
    mat4 saturationMatrix( float saturation )
    {
        vec3 luminance = vec3( 0.3086, 0.6094, 0.0820 );
        
        float oneMinusSat = 1.0 - saturation;
        
        vec3 red = vec3( luminance.x * oneMinusSat );
        red+= vec3( saturation, 0, 0 );
        
        vec3 green = vec3( luminance.y * oneMinusSat );
        green += vec3( 0, saturation, 0 );
        
        vec3 blue = vec3( luminance.z * oneMinusSat );
        blue += vec3( 0, 0, saturation );
        
        return mat4( red,     0,
                     green,   0,
                     blue,    0,
                     0, 0, 0, 1 );
    }
    
    
    void mainImage()
    {
        vec4 color = texture( iChannel0, fragCoord/iResolution.xy );
        
        fragColor = brightnessMatrix( brightness ) *
                    contrastMatrix( contrast ) * 
                    saturationMatrix( saturation ) *
                    color;
    }
    ')
	/*@:glVertexSource('
		#pragma header

			uniform mat4 gl_ModelViewMatrix;
			uniform mat4 gl_ProjectionMatrix;

			attribute vec4 gl_Vertex;

			void main() 
			{
				gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
			}

		')
	 */
	public function new()
	{
		super();
	}
}