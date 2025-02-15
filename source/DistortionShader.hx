import flixel.system.FlxAssets.FlxShader;

class DistortionShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header
    vec2 computeUV( vec2 uv, float k, float kcube ){
    
    vec2 t = uv - .5;
    float r2 = t.x * t.x + t.y * t.y;
	float f = 0.;
    
    if( kcube == 0.0){
        f = 1. + r2 * k;
    }else{
        f = 1. + r2 * ( k + kcube * sqrt( r2 ) );
    }
    
    vec2 nUv = f * t + .5;
    nUv.y = 1. - nUv.y;
 
    return nUv;
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    float k = 1.0 * sin( iTime * .9 );
    float kcube = .5 * sin( iTime );
    
    float offset = .1 * sin( iTime * .5 );
    
    float red = texture( iChannel0, computeUV( uv, k + offset, kcube ) ).r; 
    float green = texture( iChannel0, computeUV( uv, k, kcube ) ).g; 
    float blue = texture( iChannel0, computeUV( uv, k - offset, kcube ) ).b; 
    
    fragColor = vec4( red, green,blue, 1. );

}
    ')
	// From here http://www.francois-tarlier.com/blog/cubic-lens-distortion-shader/
	public function new()
	{
		super();
	}
}