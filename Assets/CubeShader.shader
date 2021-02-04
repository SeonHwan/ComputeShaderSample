Shader "Custom/CubeShader"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel"="4.5"}
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            // Use same blending / depth states as Standard shader
            Blend One Zero
            ZWrite On
            Cull Back

            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 4.5

            #pragma editor_sync_compilation
            
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #pragma vertex vert;
            #pragma fragment frag;
            
            StructuredBuffer<float3> _Positions;
            
            struct Input
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
            };

            float4x4 RotateYMatrix(float r)
            {
                float sina, cosa;
                sincos(r, sina, cosa);
                
                float4x4 m;

                m[0] = float4(cosa, 0, -sina, 0);
                m[1] = float4(0, 1, 0, 0);
                m[2] = float4(sina, 0, cosa, 0);
                m[3] = float4(0, 0, 0, 1);

                return m;
            }

            float4x4 PositionMatrix(float3 pos)
            {
                float4x4 m;

                m[0] = float4(1,0,0,pos.x);
                m[1] = float4(0,1,0,pos.y);
                m[2] = float4(0,0,1,pos.z);
                m[3] = float4(0,0,0,1);

                return m;
            }
            v2f vert (Input v, uint instanceID : SV_InstanceID)
            {
                float4x4 tfM = mul(PositionMatrix(_Positions[instanceID]), RotateYMatrix(_Time.y));
                float4 worldPos = mul(tfM, v.positionOS);
                v2f o;
                o.pos = mul(unity_MatrixVP, worldPos);
                o.normal = mul(v.normalOS, (float3x3)Inverse(tfM));
                
                return o;
            }

            half4 frag(v2f i) : SV_TARGET
            {
                Light mainLight = GetMainLight();
                i.normal = normalize(i.normal);

                float3 lambert = LightingLambert(mainLight.color, mainLight.direction, i.normal);
                half3 ambient = SampleSH(i.normal);

                lambert *= mainLight.distanceAttenuation * mainLight.shadowAttenuation;
                lambert += ambient;
                
                return half4(lambert, 1);
            }
            
            ENDHLSL
        }
    }
}
