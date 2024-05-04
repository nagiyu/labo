#!/bin/bash

# プロセスをキルする関数
kill_process() {
    kill "$1" # プロセスIDを受け取ってキルする
}

# バックグラウンドでプロセスを起動し、IDを取得してファイルに追記する関数
start_background_process() {
    nohup sh -c 'cd Labo/bin/Release/net7.0/linux-x64/publish && dotnet Labo.dll' >> output.log 2>&1 &
    echo $! >> process_ids.txt
}

kill_tree () {
    local parent_pid="$1"
    local children="$(pgrep -P "$parent_pid")"
    
    for child_pid in $children; do
        kill_tree "$child_pid"
    done
    
    kill "$parent_pid"
}

# メイン処理
main() {
    # プロセスIDを控えるファイル
    ids_file="process_ids.txt"

    # IDを控えるファイルからIDを読み込んでループする
    while IFS= read -r pid; do
        # プロセスをキルする
        # kill_process "$pid"
        kill_tree "$pid"
        # プロセスIDをファイルから削除する
        sed -i "/^$pid$/d" "$ids_file"
    done < "$ids_file"

    # バックグラウンドでプロセスを起動してIDを控える
    start_background_process
}

# メイン処理を呼び出す
main
