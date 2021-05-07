require 'rails_helper'
require 'support/model/validation_helper'

RSpec.describe Article, type: :model do
  describe 'Validation チェック' do
    let(:target) { build(:article) }

    subject {
      target.valid?
      target.errors[attribute]
    }

    describe 'タイトル(title)' do
      let(:attribute) { :title }

      it '空の値が無効であること' do
        target[attribute] = nil
        is_expected.to include('を入力してください')
      end
    end

    describe 'スラッグ(slag)' do
      let(:attribute) { :slag }

      it '空の値が無効であること' do
        target[attribute] = nil
        is_expected.to include('を入力してください')
      end

      context '文字列長チェック(12~50)' do

        it '35文字（範囲内）が有効であること' do
          target[attribute] = "a" * 35
          is_expected.to_not include('は50文字以内で入力してください')
          is_expected.to_not include('は12文字以上で入力してください')
        end

        it '11文字が無効であること' do
          target[attribute] = "a" * 11
          is_expected.to include('は12文字以上で入力してください')
        end

        it '12文字が有効であること' do
          target[attribute] = "a" * 12
          is_expected.to_not include('は50文字以内で入力してください')
          is_expected.to_not include('は12文字以上で入力してください')
        end

        it '50文字が有効であること' do
          target[attribute] = "a" * 50
          is_expected.to_not include('は50文字以内で入力してください')
          is_expected.to_not include('は12文字以上で入力してください')
        end

        it '51文字が無効であること' do
          target[attribute] = "a" * 51
          is_expected.to include('は50文字以内で入力してください')
        end
      end

      describe 'パターンチェック(半角英数字、ハイフン)' do
        it '半角英字だけの値が有効であること' do
          target[attribute] = ('a'..'z').to_a.join()
          is_expected.to_not include('は"a-z0-9"と"-"の組み合わせで入力してください')
        end

        it '半角数字だけの値が有効であること' do
          target[attribute] = ('0'..'9').to_a.join()
          is_expected.to_not include('は"a-z0-9"と"-"の組み合わせで入力してください')
        end

        it 'ハイフンだけの値が有効であること' do
          target[attribute] = '-'
          is_expected.to_not include('は"a-z0-9"と"-"の組み合わせで入力してください')
        end

        it '許容される全てのパターンを含む値が有効であること' do
          target[attribute] = [*'a'..'z', *'0'..'9', '-'].join()
          is_expected.to_not include('は"a-z0-9"と"-"の組み合わせで入力してください')
        end

        it '半角大文字英字を含む値が無効であること' do
          target[attribute] = ('A'..'Z').to_a.join()
          is_expected.to include('は"a-z0-9"と"-"の組み合わせで入力してください')
        end

        it '許容されない記号を含む値が無効であること' do
          target[attribute] = '@;:[]_/.,<>?}{*+~=-^¥|!#$%&()'
          is_expected.to include('は"a-z0-9"と"-"の組み合わせで入力してください')
        end
      end

      context '一意性チェック' do
        it '重複しない値が有効であること' do
          other = create(:article)
          is_expected.to_not include('はすでに存在します')
        end

        it '重複した値が無効であること' do
          other = create(:article)
          target.user = other.user
          target.slag = other.slag
          is_expected.to include('はすでに存在します')
        end
      end
    end

    describe '絵文字(emoji)' do
      let(:attribute) { :emoji }

      it '空の値が無効であること' do
        target[attribute] = nil
        is_expected.to include('を入力してください')
      end

      context '文字列長チェック(1文字)' do
        it '0文字が無効であること' do
          target[attribute] = ''
          is_expected.to include('は1文字で入力してください')
        end

        it '1文字が有効であること' do
          target[attribute] = '✊'
          is_expected.to_not include('は1文字で入力してください')
        end

        it '2文字が無効であること' do
          target[attribute] = '✊✊'
          is_expected.to include('は1文字で入力してください')
        end
      end

      context 'パターンチェック(絵文字)' do
        it '絵文字が有効であること' do
          target[attribute] = '✊'
          is_expected.to_not include('は絵文字で入力してください')
        end

        it '半角英字が無効であること' do
          target[attribute] = ('a'..'z').to_a.join()
          is_expected.to include('は絵文字で入力してください')
        end

        it '大文字半角英字が無効であること' do
          target[attribute] = ('A'..'Z').to_a.join()
          is_expected.to include('は絵文字で入力してください')
        end

        it '数字が無効であること' do
          pending('p{Emoji}の正規表現が数字を許容しているため失敗する see: https://monmon.hateblo.jp/entry/2019/10/03/132951')
          target[attribute] = ('0'..'9').to_a.join()
          is_expected.to include('は絵文字で入力してください')
        end

        it '記号が無効であること' do
          pending('p{Emoji}の正規表現が一部記号を許容しているため失敗する。 see: https://monmon.hateblo.jp/entry/2019/10/03/132951')
          target[attribute] = '*'
          is_expected.to include('は絵文字で入力してください')
        end

        it '日本語が無効であること' do
          target[attribute] = ('あ'..'ん').to_a.join()
          is_expected.to include('は絵文字で入力してください')
        end
      end
    end

    describe 'Zennタイプ(category)' do
      let(:attribute) { :category }

      it '空の値が無効であること' do
        target[attribute] = nil
        is_expected.to include('を入力してください')
      end

      it 'デフォルト値が"tech"であること' do
        pending("migration対応が必要")
        target = Article.new
        expect(target.category).to eq 'tech'
      end
      
      context 'パターンチェック("tech" or "idea")' do
        it 'techの文字列が有効であること' do
          target[attribute] = 'tech'
          is_expected.to_not include('は一覧にありません')
        end

        it 'ideaの文字列が有効であること' do
          target[attribute] = 'idea'
          is_expected.to_not include('は一覧にありません')
        end

        it 'techを含む文字列が無効であること' do
          target[attribute] = 'techhoge'
          is_expected.to include('は一覧にありません')
        end

        it 'ideaを含む文字列が無効であること' do
          target[attribute] = 'ideahoge'
          is_expected.to include('は一覧にありません')
        end

        it '適当な文字列が無効であること' do
          target[attribute] = 'ajksdhfkasei'
          is_expected.to include('は一覧にありません')
        end
      end 
    end

    describe '公開設定published' do
      let(:attribute) { :published }

      it 'デフォルト値が"true"であること' do
        target = Article.new
        expect(target.published).to eq true
      end

      context 'パターンチェック(true or false)' do 
        it '真偽値trueが有効であること' do
          target[attribute] = true
          is_expected.to_not include('は一覧にありません')
        end

        it '真偽値falseが有効であること' do
          target[attribute] = false
          is_expected.to_not include('は一覧にありません')
        end

        it 'trueと評価される真偽値以外の値が有効であること' do
          target[attribute] = 1
          is_expected.to_not include('は一覧にありません')
        end

        it 'falseと評価される真偽値以外の値が無効であること' do
          target[attribute] = nil
          is_expected.to include('は一覧にありません')
        end
      end
    end

    describe 'Qiita 記事ID(qiita_uid)' do
      let(:attribute) { :qiita_uid }

      it '空の値が無効であること' do
        target[attribute] = nil
        is_expected.to include('を入力してください')
      end
    end

    describe 'Qiita 記事URL(qiita_url)' do
      let(:attribute) { :qiita_url }

      it '空の値が無効であること' do
        target[attribute] = nil
        is_expected.to include('を入力してください')
      end
    end

    describe 'Qiita 記事作成時間(qiita_created_at)' do
      let(:attribute) { :qiita_created_at }

      it '空の値が無効であること' do
        target[attribute] = nil
        is_expected.to include('を入力してください')
      end
    end

    describe '記事内容(body)' do
      let(:attribute) { :body }

      it '空の値が有効であること' do
        target[attribute] = nil
        is_expected.to_not include('を入力してください')
      end
    end

    describe '作成ユーザーID(user_id)' do
      let(:attribute) { :user_id }

      it '空の値が無効であること' do
        target[attribute] = nil
        is_expected.to include('を入力してください')
      end
    end

  end
end
