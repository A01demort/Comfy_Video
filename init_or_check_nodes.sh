#!/bin/bash
set -e

echo "🌀 RunPod 재시작 시 의존성 복구 시작"

cd /workspace/ComfyUI/custom_nodes || {
  echo "⚠️ custom_nodes 디렉토리 없음. ComfyUI 설치 전일 수 있음"
  exit 0
}

for d in */; do
  if [ -f "$d/requirements.txt" ]; then
    echo "📦 $d 의존성 설치 중..."
    pip install -r "$d/requirements.txt" || echo "⚠️ $d 의존성 설치 실패 (무시하고 진행)"
  fi
done

echo "✅ 모든 커스텀 노드 의존성 복구 완료"
echo "🚀 다음 단계로 넘어갑니다"
