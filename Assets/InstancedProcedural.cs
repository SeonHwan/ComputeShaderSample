using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InstancedProcedural : MonoBehaviour
{
    [SerializeField] private Material material;

    [SerializeField] private Mesh mesh;

    [SerializeField] private int count;
    
    private ComputeBuffer positionBuffer;
    private Vector3[] positions;
    private static readonly int Positions = Shader.PropertyToID("_Positions");

    private void Start()
    {
        positions = new Vector3[count * count];
    }

    private void Update()
    {
        positionBuffer?.Release();
        positionBuffer = new ComputeBuffer(count * count, 12);
        
        for (int i = 0; i < count; ++i)
        {
            for (int j = 0; j < count; ++j)
            {
                float x = (-(count * 0.5f) + i) * 2;
                float z = (-(count * 0.5f) + j) * 2;
                positions[(count * i) + j] = new Vector3(x, 0f, z);
            }
        }
        positionBuffer.SetData(positions);
        material.SetBuffer(Positions, positionBuffer);
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
