#!/usr/bin/env bash
# 手元のPCで動かすためのスクリプト。初回は仮想環境の作成から自動でやります。
#
#   ./run.sh verify        メルカリと Slack に繋がるか診断する（まずこれ）
#   ./run.sh dry           Slack に送らず、結果だけ表示する
#   ./run.sh once          本番と同じ動作を1回だけ実行する
#   ./run.sh add           商品を追加する（対話式）
#   ./run.sh test          テストを実行する
#
# Slack の設定は .env に書くか、環境変数で渡してください。
#   SLACK_BOT_TOKEN=xoxp-...
#   SLACK_CHANNEL=U...

set -euo pipefail
cd "$(dirname "$0")"

PYTHON="${PYTHON:-python3}"
VENV=".venv"

if [ ! -x "$VENV/bin/python" ]; then
  echo "初回セットアップ: 仮想環境を作ります…"
  "$PYTHON" -m venv "$VENV"
  "$VENV/bin/pip" install --quiet --upgrade pip
  "$VENV/bin/pip" install --quiet -r requirements-dev.txt
  echo "完了しました。"
  echo
fi

# .env があれば読み込む（コメント行と空行は無視）。
if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

case "${1:-verify}" in
  verify) exec "$VENV/bin/python" -m src.main --verify ;;
  dry)    exec "$VENV/bin/python" -m src.main --dry-run --report ;;
  once)   exec "$VENV/bin/python" -m src.main --report ;;
  add)    exec "$VENV/bin/python" scripts/add_product.py ;;
  test)   exec "$VENV/bin/python" -m pytest -q ;;
  market) shift; exec "$VENV/bin/python" scripts/probe.py market "$@" ;;
  *)
    echo "使い方: ./run.sh [verify|dry|once|add|test|market]" >&2
    exit 2
    ;;
esac
