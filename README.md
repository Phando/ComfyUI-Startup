# Alternate Startup Scripts for ComfyUI
> [!NOTE]
> These scripts set up a models folder outside your comfyPortable instance. 
> They will move your original *comfyui/ComfyUI/models* folder to *genai/models* and replace it with a link.
> The external models folder is helpful for running multiple comfy instances on the same machine as well as for reinstalls. 

Are you seeing errors in your startup terminal? These scripts help clear common issues. 

One script is for regular use and the other script is for after updates and during initial comfy setup.

The scripts will modify and then assume the directory structure:
```
genai/
├─ comfyui/
│  ├─ ComfyUI/
│  │  ├─ custom_nodes/
├─ input/
├─ models/
│  ├─ checkpoints/
│  ├─ loras/
├─ output/
```
