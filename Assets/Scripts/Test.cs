using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    public Shader shader;
    // Start is called before the first frame update
    void Start()
    {
        this.gameObject.GetComponent<Material>().shader=shader;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
