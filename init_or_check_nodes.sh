#!/bin/bash
set -e
echo "🌀 커스텀 노드 자동 점검 및 설치 시작"

cd /workspace/ComfyUI/custom_nodes || exit 1

declare -A repos=(
  ["ComfyUI-Manager"]="https://github.com/ltdrdata/ComfyUI-Manager.git"
  ["ComfyUI-Custom-Scripts"]="https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git"
  ["rgthree-comfy"]="https://github.com/rgthree/rgthree-comfy.git"
  ["was-node-suite-comfyui"]="https://github.com/WASasquatch/was-node-suite-comfyui.git"
  ["ComfyUI-KJNodes"]="https://github.com/kijai/ComfyUI-KJNodes.git"
  ["ComfyUI_essentials"]="https://github.com/cubiq/ComfyUI_essentials.git"
  ["ComfyUI-GGUF"]="https://github.com/city96/ComfyUI-GGUF.git"
  ["ComfyUI-TeaCache"]="https://github.com/welltop-cn/ComfyUI-TeaCache.git"
  ["ComfyUI_AdvancedRefluxControl"]="https://github.com/kaibioinfo/ComfyUI_AdvancedRefluxControl.git"
  ["ComfyUI_Comfyroll_CustomNodes"]="https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git"
  ["PuLID_ComfyUI"]="https://github.com/cubiq/PuLID_ComfyUI.git"
  ["ComfyUI-PuLID-Flux-Enhanced"]="https://github.com/sipie800/ComfyUI-PuLID-Flux-Enhanced.git"
  ["ComfyUI-ReActor"]="https://github.com/Gourieff/ComfyUI-ReActor.git"
  ["ComfyUI-Easy-Use"]="https://github.com/yolain/ComfyUI-Easy-Use.git"
  ["ComfyUI-AdvancedLivePortrait"]="https://github.com/PowerHouseMan/ComfyUI-AdvancedLivePortrait.git"
  ["ComfyUI-VideoHelperSuite"]="https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git"
  ["ComfyUI-Detail-Daemon"]="https://github.com/Jonseed/ComfyUI-Detail-Daemon.git"
  ["ComfyUI_UltimateSDUpscale"]="https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git"
  ["comfyUI_FrequencySeparation_RGB-HSV"]="https://github.com/risunobushi/comfyUI_FrequencySeparation_RGB-HSV.git"
  ["ComfyUI_bnb_nf4_fp4_Loaders"]="https://github.com/silveroxides/ComfyUI_bnb_nf4_fp4_Loaders.git"
)

for dir in "${!repos[@]}"; do
  if [ -d "$dir/.git" ]; then
    echo "✅ $dir 이미 설치되어 있음 (스킵)"
  else
    echo "📥 $dir 설치 중..."
    git clone "${repos[$dir]}" "$dir" || echo "⚠️ $dir 설치 실패"
  fi
done

echo "✅ 커스텀 노드 자동 점검 완료"
