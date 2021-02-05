using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InstancedProcedural : MonoBehaviour
{
    [SerializeField] private ComputeShader computeShader;
    [SerializeField] private Material material;

    [SerializeField] private Mesh mesh;

    [SerializeField] private int count;
    
    private ComputeBuffer positionBuffer;
    
    private static readonly int PositionID = Shader.PropertyToID("_Positions");
    private static readonly int ResolutionID = Shader.PropertyToID("_Resolution");
    private static readonly int TimeID = Shader.PropertyToID("_Time");
    

    private void Update()
    {
        positionBuffer?.Release();
        positionBuffer = new ComputeBuffer(count * count, 4 * 16);
        
        computeShader.SetInt(ResolutionID, count);
        computeShader.SetFloat(TimeID, Time.time);
        computeShader.SetBuffer(0, PositionID, positionBuffer);
        
        //resolution : 128
        //16,384 개의 스레드가 돌아야 함
        //커널함수 하나가 8 * 8 = 64 개의 스레드를 갖고 있으니
        //16,384 / 64 = 256 개의 그룹을 돌려야 함
        //루트256 = 16 이므로 각 그룹은 16이어야 함
        //16은 즉 resolution / 8 과 같으므로
        //groups = resoltion / 8 임
        int groups = Mathf.CeilToInt(count / 8f);
        computeShader.Dispatch(0, groups, groups, 1);
        
        material.SetBuffer(PositionID, positionBuffer);
        Graphics.DrawMeshInstancedProcedural(
            mesh, 0, material, new Bounds(Vector3.zero, Vector3.one), count * count
        );
    }
    
    private void OnDisable()
    {
        positionBuffer?.Release();
        positionBuffer = null;
    }
}
