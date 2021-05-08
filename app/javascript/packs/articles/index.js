import '../../css/articles/index.css';

/*
 * 削除モーダルの挙動制御Function
 */
const $deleteModal = $("#delete-modal");
const URL_PREFIX   = `${location.protocol}//${location.host}`;
const ARTICLE_DELETE_URL_TEMPLATE = `${URL_PREFIX}/articles/:id`;

function setTitle(title) {
  $deleteModal.find("#target-title").text(title);
}

function setHref(id) {
  console.log(id)
  const url = ARTICLE_DELETE_URL_TEMPLATE.replace(":id", id);
  $deleteModal.find(".delete-button").attr("href", url);
}

function showDeleteModal() {
  $deleteModal.show();
}

function hideDeleteModal() {
  $deleteModal.hide();
}

/*
 * tr要素（Artileの詳細）の挙動制御Function
 */
function getArticleTr(id) {
  return $(`#tr-${id}`);
}

function getSlag(id) {
  let $target = getArticleTr(id);
  return $target.find(".slag-input").val();
}

function getTitle(id) {
  let $target = getArticleTr(id);
  return $target.find(".title-input").val();
}

/*
 * イベント定義 
 */
$(".show-delete-modal").click(function(event) {
  let id = $(this).data("id");
  let title = getTitle(id);
  setHref(id);
  setTitle(title);
  showDeleteModal();
});

$deleteModal.find(".hidden-delete-modal").click(function(event) {
  hideDeleteModal();
})
