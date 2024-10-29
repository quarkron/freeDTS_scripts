# Tutorial

These scripts automate FreeDTS runs given starting and final gammaV values and some arguments. **Note that this uses FreeDTSv2.0 from weria-pezeshkian/FreeDTSv2.0.git**.

**Steps**

1. Put gen_inputs.sh, gen_outputs.sh, input_template_weria2.dts, topol.q, top.top on your FreeDTS folder.
2. Make sure that FreeDTS_openMP is compiled.
3. Run gen_inputs.sh with the following arguments:
    | **Keyword**   | **Description** | **Default Value**  |
    | :----:      |    :----:   |   :----: |
    | -f          | Folder name where to store input.dts files | inputs1 |
    | -t   | Filename of template dts file | input_template_weria2.dts |
    | -gi  | Initial gammaV value | 1.0 |
    | -gf  | Final gammaV value   | 0.90 |
    | -i   | Number of MC steps going from spherical vesicle to gammaV_init | 100000  |
    | -c   | Number of MC steps after reaching gammaV_init from a sphere    | 100000  |
    | -s   | Decrement between consecutive gammaV | 0.01|
    | -a   | Value of gammaV to initiate inclusions | 1.0 |
    | -d   | Protein inclusion density | 0.02 |
   
    Increase -i (MC equilibration steps) accordingly if -gi is less than 1.0. 

4. Run gen_outputs.sh with the following arguments:
   | **Keyword**   | **Description** | **Default Value**  |
    | :----:      |    :----:   |   :----: |
    | -f          | Folder name where to store output files | outputs1 |
    | -n   | Number of threads to use | 32 |
    | -r  | Number of replicates per gammaV | 1 |

    The outputs1 folder will contain folders containing trajectories per gammaV and per replicate. 
    If more shapes are needed, increase replicates.

