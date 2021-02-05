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
