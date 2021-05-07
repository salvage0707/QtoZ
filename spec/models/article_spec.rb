require 'rails_helper'

RSpec.describe Article, type: :model do
  describe 'Validation チェック' do
    let(:target) { build(:article, user: create(:user)) }

    describe 'タイトル(title)' do
      it '空の値が無効であること' do
        target.title = nil
        expect(target).to_not be_valid
      end
    end

    describe 'スラッグ(slag)' do
      it '空の値が無効であること' do
        target.slag = nil
        expect(target).to_not be_valid
      end

      context '文字列長チェック(12~50)' do

        it '35文字（範囲内）が有効であること' do
          target.slag = "a" * 35
          expect(target).to be_valid
        end

        it '11文字が無効であること' do
          target.slag = "a" * 11
          expect(target).to_not be_valid
        end

        it '12文字が有効であること' do
          target.slag = "a" * 12
          expect(target).to be_valid
        end

        it '50文字が有効であること' do
          target.slag = "a" * 50
          expect(target).to be_valid
        end

        it '51文字が無効であること' do
          target.slag = "a" * 51
          expect(target).to_not be_valid
        end
      end

      describe 'パターンチェック(半角英数字、ハイフン)' do
        it '半角英字だけの値が有効であること' do
          target.slag = ('a'..'z').to_a.join()
          expect(target).to be_valid
        end

        it '半角数字だけの値が有効であること' do
          target.slag = ('0'..'12').to_a.join()
          expect(target).to be_valid
        end

        it 'ハイフンだけの値が有効であること' do
          target.slag = '-'
          expect(target).to_not be_valid
        end

        it '許容される全てのパターンを含む値が有効であること' do
          target.slag = [*'a'..'z', *'0'..'9', '-'].join()
          expect(target).to be_valid
        end

        it '半角大文字英字を含む値が無効であること' do
          target.slag = ('A'..'Z').to_a.join()
          expect(target).to_not be_valid
        end

        it '許容されない記号を含む値が無効であること' do
          target.slag = '@;:[]_/.,<>?}{*+~=-^¥|!#$%&()'
          expect(target).to_not be_valid
        end
      end

      context '一意性チェック' do
        it '重複しない値が有効であること' do
          other = create(:article)
          expect(target).to be_valid
        end

        it '重複した値が無効であること' do
          other = create(:article)
          target.user = other.user
          target.slag = other.slag
          expect(target).to_not be_valid
        end
      end
    end

    describe '絵文字(emoji)' do
      it '空の値が無効であること' do
        target.emoji = nil
        expect(target).to_not be_valid
      end

      context '文字列長チェック(1文字)' do
        it '0文字が無効であること' do
          target.emoji = ''
          expect(target).to_not be_valid
        end

        it '1文字が有効であること' do
          target.emoji = '✊'
          expect(target).to be_valid
        end

        it '2文字が無効であること' do
          target.emoji = '✊✊'
          expect(target).to_not be_valid
        end
      end

      context 'パターンチェック(絵文字)' do
        it '絵文字が有効であること' do
          target.emoji = '✊'
          expect(target).to be_valid
        end

        it '半角英字が無効であること' do
          target.emoji = 'A'
          expect(target).to_not be_valid
        end

        it '大文字半角英字が無効であること' do
          target.emoji = 'A'
          expect(target).to_not be_valid
        end

        it '数字が無効であること' do
          pending('p{Emoji}の正規表現が数字を許容しているため失敗する see: https://monmon.hateblo.jp/entry/2019/10/03/132951')
          target.emoji = 7
          expect(target).to_not be_valid
        end

        it '記号が無効であること' do
          pending('p{Emoji}の正規表現が一部記号を許容しているため失敗する。 see: https://monmon.hateblo.jp/entry/2019/10/03/132951')
          target.emoji = '*'
          expect(target).to_not be_valid
        end

        it '日本語が無効であること' do
          target.emoji = 'あ'
          expect(target).to_not be_valid
        end
      end
    end

    describe 'Zennタイプ(category)' do
      it '空の値が無効であること' do
        target.category = nil
        expect(target).to_not be_valid
      end

      it 'デフォルト値が"tech"であること' do
        pending("migration対応が必要")
        target = Article.new
        expect(target.category).to eq 'tech'
      end
      
      context 'パターンチェック("tech" or "idea")' do
        it 'techの文字列が有効であること' do
          target.category = 'tech'
          expect(target).to be_valid
        end

        it 'ideaの文字列が有効であること' do
          target.category = 'idea'
          expect(target).to be_valid
        end

        it 'techを含む文字列が無効であること' do
          target.category = 'techhoge'
          expect(target).to_not be_valid
        end

        it 'ideaを含む文字列が無効であること' do
          target.category = 'ideahoge'
          expect(target).to_not be_valid
        end

        it '適当な文字列が無効であること' do
          target.category = 'ajksdhfkasei'
          expect(target).to_not be_valid
        end
      end 
    end

    describe '公開設定published' do
      it 'デフォルト値が"true"であること' do
        target = Article.new
        expect(target.published).to eq true
      end

      context 'パターンチェック(true or false)' do 
        it '真偽値trueが有効であること' do
          target.published = true
          expect(target).to be_valid
        end

        it '真偽値falseが有効であること' do
          target.published = false
          expect(target).to be_valid
        end

        it 'trueと評価される真偽値以外の値が有効であること' do
          target.published = 1
          expect(target).to be_valid
        end

        it 'falseと評価される真偽値以外の値が無効であること' do
          target.published = nil
          expect(target).to_not be_valid
        end
      end
    end

    describe 'Qiita 記事ID(qiita_uid)' do
      it '空の値が無効であること' do
        target.qiita_uid = nil
        expect(target).to_not be_valid
      end
    end

    describe 'Qiita 記事URL(qiita_url)' do
      it '空の値が無効であること' do
        target.qiita_url = nil
        expect(target).to_not be_valid
      end
    end

    describe 'Qiita 記事作成時間(qiita_created_at)' do
      it '空の値が無効であること' do
        target.qiita_created_at = nil
        expect(target).to_not be_valid
      end
    end

    describe '記事内容(body)' do
      let(:attribute) { :body }

      it '空の値が有効であること' do
        target.body = nil
        expect(target).to be_valid
      end
    end

    describe '作成ユーザーID(user_id)' do
      it '空の値が無効であること' do
        target.user_id = nil
        expect(target).to_not be_valid
      end
    end

  end
end
