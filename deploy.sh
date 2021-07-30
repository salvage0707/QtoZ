#!/bin/sh

echo "#############処理開始#############"

echo "packファイル削除"
rm -rf ./public/packs/

echo "アセットコンパイル"
RAILS_ENV=production bin/rails assets:precompile

echo "デプロイ"
gcloud app deploy

# なぜか"bin/webpack-dev-server"ができなくなるから以下実行（直したい）
yarn install

echo "#############処理終了#############"