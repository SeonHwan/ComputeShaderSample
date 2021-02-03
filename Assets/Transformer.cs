using System;
using UnityEngine;

public class Transformer : MonoBehaviour
{
    private void Update()
    {
        transform.Rotate(Vector3.up, Time.deltaTime * 50f);
    }
}