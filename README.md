# Alternate Startup Scripts for ComfyUI
> [!NOTE]
> These scripts optionally set up the models folder **outside** your comfyPortable instance. 
> You will be prompted to delete your original *genai/comfyui/ComfyUI/models* folder and replace it with a link to *genai/models*.
> Backup or move your existing models folder to *genai/models* prior to generating the link.
> The external models folder is helpful for running multiple comfy instances on the same machine as well as for reinstalls. 

### Are you seeing errors in your startup terminal? 
These scripts help clear common issues. 

One script is for regular use and the other script is for after updates and during initial comfy setup.
- run_comfy.bat - regular use
- run_comfy_util.ps1 - general setup and fixes common errors

The scripts assume the following directory structure:
```
genai/
├─ comfyui/
│  ├─ ComfyUI/
│  │  ├─ custom_nodes/
│  ├─ run_comfy.bat
│  ├─ run_comfy_util.ps1
├─ input/
├─ models/
│  ├─ checkpoints/
│  ├─ loras/
├─ output/
```
