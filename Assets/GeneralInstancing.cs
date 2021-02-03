using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GeneralInstancing : MonoBehaviour
{
    [SerializeField] private GameObject instancingTarget;

    [SerializeField] private int count;
    
    private void Start()
    {
        for (int i = 0; i < count; ++i)
        {
            for (int j = 0; j < count; ++j)
            {
                GameObject instanced = Instantiate(instancingTarget);
                instanced.gameObject.SetActive(true);
                
                float x = -(count * 0.5f) + i;
                float z = -(count * 0.5f) + j;
                instanced.transform.position = new Vector3(x * 2, 0, z * 2);
            }
        }
    }
}
