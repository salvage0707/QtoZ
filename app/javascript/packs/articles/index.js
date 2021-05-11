import '../../css/articles/index.css';

const URL_PREFIX   = `${location.protocol}//${location.host}`;

function parseJson(data) {
  var returnJson = {};
  for (let idx = 0; idx < data.length; idx++) {
    returnJson[data[idx].name] = data[idx].value
  }
  return returnJson;
}

/*
 * 削除モーダルの挙動制御Function
 */
const ARTICLE_DELETE_URL_TEMPLATE = `${URL_PREFIX}/articles/:id`;

const DeleteModal = {
  $modal: $("#delete-modal"),

  setTitle: function(title) {
    this.$modal.find("#target-title").text(title);
  },
  
  setHref: function(id) {
    const url = ARTICLE_DELETE_URL_TEMPLATE.replace(":id", id);
    const atag = this.$modal.find(".delete-button");
    atag.attr("href", url);
  },
  
  show: function() {
    this.$modal.show();
  },
  
  hide: function() {
    this.$modal.hide();
  },
}


/*
 * 更新モーダルの挙動制御Function
 */
const ARTICLE_UPDATE_URL_TEMPLATE = `${URL_PREFIX}/articles/:id`;

const UpdateModal = {
  $modal: $("#update-modal"),
  $form:  $("#update-form"),

  show: function() {
    this.$modal.show();
  },

  hide: function() {
    this.$modal.hide();
  },

  getId: function() {
    return this.$form.data("id");
  },

  setId: function(id) {
    this.$form.data("id", id);
  },

  reset: function() {
    this.setId(null);
  },

  setValueAtSlag: function(value) {
    this.$modal.find("#slag-input-area").val(value);
  },

  setValueAtTitle: function(value) {
    this.$modal.find("#title-input-area").val(value);
  },

  setValueAtEmoji: function(value) {
    this.$modal.find("#emoji-input-area").val(value);
  },

  setValueAtType: function(value) {
    this.$modal.find("#type-input-area").val(value);
  },

  setValueAtTopics: function(value) {
    this.$modal.find("#topics-input-area").val(value);
  },

  setValueAtPublished: function(value) {
    this.$modal.find("#published-input-area").val(value);
  },

  update: function() {
    // URL
    const id = this.$form.data("id");
    const url = ARTICLE_UPDATE_URL_TEMPLATE.replace(":id", id); 

    // Header
    const csrfToken = $('meta[name="csrf-token"]').attr('content');
    const headers = {
      "Content-Type": "application/json",
      "X-CSRF-Token": csrfToken
    }

    // Body
    const serialized = this.$form.serializeArray();
    const data = parseJson(serialized);

    self = this;
    $.ajax({
      url:           url,
      type:          'patch',
      dataType:      'json',
      headers:        headers,
      scriptCharset: 'utf-8',
      data:          JSON.stringify(data)
    })
    .done(function(response) {
      const articleTr = new ArticleTr(id);
      articleTr.setSlag(response["slag"]);
      articleTr.setTitle(response["title"]);
      articleTr.setEmoji(response["emoji"]);
      articleTr.setType(response["type"]);
      articleTr.setTopics(response["topics"]);
      articleTr.setPublished(response["published"]);

      self.reset();
      self.hide();
    })
    .fail(function(response) {
      console.error(response);
    });
  }
}


/*
 * tr要素（Artileの詳細）の挙動制御Function
 */
class ArticleTr {

  constructor(id) {
    if (!id) {
      throw new Error("idが存在しません")
    } 

    this.$tr = $(`#tr-${id}`);
    this.$slag  = this.$tr.find(".slag-text");
    this.$title = this.$tr.find(".title-text");
    this.$type = this.$tr.find(".type-text");
    this.$emoji = this.$tr.find(".emoji-text");
    this.$topics    = this.$tr.find(".topics-text");
    this.$published = this.$tr.find(".published-text");
  }
  
  getSlag() {
    return this.$slag.text();
  }
  
  getTitle() {
    return this.$title.text();
  }

  getEmoji() {
    return this.$emoji.text();
  }

  getType() {
    return this.$type.text();
  }

  getTopics() {
    return this.$topics.text();
  }

  getPublished() {
    return this.$published.text();
  }

  setSlag(value) {
    this.$slag.text(value);
  }
  
  setTitle(value) {
    this.$title.text(value);
  }

  setEmoji(value) {
    this.$emoji.text(value);
  }

  setType(value) {
    if (value == "tech") {
      this.$type.removeClass("article-idea");
      this.$type.addClass("article-tech");
    } else {
      this.$type.removeClass("article-tech");
      this.$type.addClass("article-idea");
    }
    this.$type.text(value);
  }

  setTopics(value) {
    this.$topics.text(value);

    const $topicsList = this.$tr.find(".topics-list");
    // 現在のtopicsを削除
    $topicsList.find("li").remove();

    // topicsを設定
    value.split(",").forEach((v) => {
      $topicsList.append('<li><span class="m-1 px-3 rounded-full text-xs bg-yellow-200">' + v + '</span></li>')
    })
  }

  setPublished(value) {
    // 現在のカラーを変更
    if (!!value) {
      this.$published.removeClass("bg-red-200");
      this.$published.removeClass("text-red-600");
      this.$published.addClass("bg-green-200");
      this.$published.addClass("text-green-600");
    } else {
      this.$published.removeClass("bg-green-200");
      this.$published.removeClass("text-green-600");
      this.$published.addClass("bg-red-200");
      this.$published.addClass("text-red-600");
    }

    this.$published.text(value);
  }
}

/*
 * イベント定義 
 */
$(".show-delete-modal").click(function(event) {
  let id = $(this).data("id");

  const articleTr = new ArticleTr(id);
  let title = articleTr.getTitle(id);

  DeleteModal.setHref(id);
  DeleteModal.setTitle(title);
  DeleteModal.show();
});

DeleteModal.$modal.find(".hidden-delete-modal").click(function(event) {
  DeleteModal.hide();
})

$(".show-update-modal").click(function(event) {
  const id = $(this).data("id");

  const articleTr = new ArticleTr(id);
  const slag  = articleTr.getSlag();
  const title = articleTr.getTitle();
  const emoji = articleTr.getEmoji();
  const type  = articleTr.getType();
  const topics    = articleTr.getTopics();
  const published = articleTr.getPublished();

  if (UpdateModal.getId() != id) {
    UpdateModal.setId(id);
    UpdateModal.setValueAtSlag(slag);
    UpdateModal.setValueAtTitle(title);
    UpdateModal.setValueAtEmoji(emoji);
    UpdateModal.setValueAtType(type);
    UpdateModal.setValueAtTopics(topics);
    UpdateModal.setValueAtPublished(published);
  }

  UpdateModal.show();
});

UpdateModal.$modal.find(".hidden-update-modal").click(function(event) {
  UpdateModal.hide();
})

UpdateModal.$modal.find(".update-button").click(function(event) {
  UpdateModal.update();
})
