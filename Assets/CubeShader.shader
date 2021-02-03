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

            v2f vert (Input v, uint instanceID : SV_InstanceID)
            {
                float3 data = _Positions[instanceID];
                
                float3 localPos = v.positionOS.xyz;
                float3 worldPos = data.xyz + localPos;
                
                v2f o;
                o.pos = mul(unity_MatrixVP, float4(worldPos, 1.0f));
                o.normal = TransformObjectToWorldNormal(v.normalOS);
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
