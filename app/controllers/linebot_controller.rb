class LinebotController < ApplicationController
  require 'line/bot'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)
    events.each do |event|
      case event
      # メッセージが送信された場合の対応
      when Line::Bot::Event::Message
        case event.type
        # ユーザーからテキスト形式のメッセージが送られて来た場合
        when Line::Bot::Event::MessageType::Text
          # event.message['text']：ユーザーから送られたメッセージ
          input = event.message['text']
          explain = "数字を選択してください\n\n↓↓↓↓↓\n1. 「最近太った？笑」\n2. 「ごはんでも行く？」\n3. 「元気出していこう！」\n4. 「そういう日もあるさ！」"

          case input
          when "1"
            push = ["20kg太りましたけど何か？（怒）", "はぁ？？", "本当にデリカシーがないんですね。\n小学生からやり直した方がいいですよ。"].sample
          when "2"
            push = ["あん？？どういう状況か分かってるんですか？（怒）", "ダイエット中なんですみません。\nあと目標まで10kg減なんです。", "おごりですね。ごちそうさまです！！（どや）"].sample
          when "3"
            push = ["この状況でどうやって元気出すんですか？\nとりあえず焼肉おごってください。", "はん？？どつきますよ？（怒）"].sample
          when "4"
            push = "なんて日だ！！！！！！"
          else
            push = "説明をちゃんと読んでください。数字を選んでって言ってるじゃないですか。\n怒りますよ。"
          end
        end
        
        message = [{ type: 'text', text: push }, { type: 'text', text: explain }]

        client.reply_message(event['replyToken'], message)
    end
    head :ok
  end

  private

    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end
end
