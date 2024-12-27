// extern float speed
extern float angular;
extern vec2 speed;
extern float t;
extern float seed;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords){
	vec3 c = vec3(angular*angular+dot(speed,speed));
	return vec4(c,0.5*sin(t*seed)*sin(t*seed));
}