//!HOOK MAIN
//!BIND HOOKED
//!DESC Grayscale Shader

vec4 hook() {
    vec4 color = HOOKED_tex(HOOKED_pos);
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    return vec4(vec3(gray), color.a);
}