Shader "Holistic/SphereLambertLit"
{
    SubShader
    {
        Tags { "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 wPos : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            #define STEPS 128
            #define STEP_SIZE 0.05
            #define SPHERE_POS float3(0, 0, 0)

            bool SphereHit(float3 pos, float3 center, float radius)
            {
                return distance(pos, center) < radius;
            }

            float3 RaymarchHit(float3 position, float3 direction)
            {
                for(int i = 0; i < STEPS; i++)
                {
                    if (SphereHit(position, SPHERE_POS, 0.5))
                    {
                        return position;
                    }
                    position += direction * STEP_SIZE;
                }
                return float3(0, 0, 0);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewDirection = normalize(i.wPos - _WorldSpaceCameraPos);
                float3 worldPosition = i.wPos;
                fixed3 depth = RaymarchHit(worldPosition, viewDirection);
                
                float3 wNormal = normalize(depth - SPHERE_POS);
                float ndotl = max( 0, dot( wNormal, _WorldSpaceLightPos0.xyz ) );

                if (length(depth) == 0)
                {
                    return fixed4(0, 0, 0, 0);
                }
                else
                {
                    return fixed4(1 * ndotl, 0, 0, 1);
                }
            }
            ENDCG
        }
    }
}
