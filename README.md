# IP固定シェルスクリプト

> Relese 1.0.0 [英語,日本]

## 利用可能なOS
- Ubuntu Desktop 18.04 LTS 以上
- Ubuntu Server 18.04 LTS 以上
- Ubuntu Desktop / Server 18.04 LTS 以上 がベースのOS

## 利用方法

### 直接取得

`$ curl -OL https://raw.githubusercontent.com/hikaproj/Set_Static_IP/refs/heads/main/set_static_ip.sh`
`$ chmod +x set_static_ip.sh`
`$ ./set_static_ip.sh`

### ここからダウンロード

1. 以下のリンクからダウンロード
> [set_static_ip.sh](https://setstaticip.hikaproj.f5.si/set_static_ip.sh)

> [!TIP]
> 上記のリンクでダウンロードできない際は[こちら](https://raw.githubusercontent.com/hikaproj/Set_Static_IP/refs/heads/main/varsion/main/en-jp/1.0.0/set_static_ip.sh)からダウンロードして下さい。

2. 実行
`$ chmod +x set_static_ip.sh`
`$ ./set_static_ip.sh`

## 利用イメージ
<img width="1536" height="1024" src="https://github.com/user-attachments/assets/2b198d18-dea5-4d96-875e-beb74788f7e8" />
<img width="768" height="1024" src="https://github.com/user-attachments/assets/1a605cd0-06ad-4510-8984-fbc73e97cf6e" />

## オプション

- リストアオプション <br>
エラーが発生した際、リストアオプションで以前の状態に戻すことができます。
`$ ./set_static_ip.sh --restore`

<img width="768" height="1024" src="https://github.com/user-attachments/assets/ec419e43-cae2-4aeb-aa4c-e9029de19a21" />
