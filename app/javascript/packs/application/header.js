import '../../css/application/header.css'

$(() => {
  // ヘッダーのユーザーメニュー切り替え
  $('#user-menu-button').on('click', () => {
    $('#user-menu').toggleClass('hidden');
  });

  // ログインのモーダル
  $('.sign-in-modal-button').on('click', (e) => {
    e.preventDefault();
    toggleModal();
  });
  $('.modal-overlay').on('click',toggleModal);
  $('.modal-close').on('click',toggleModal);

  function toggleModal () {
    let modal = $('.sign-in-modal');
    modal.toggleClass('opacity-0');
    modal.toggleClass('pointer-events-none');
    modal.toggleClass('modal-active');
  }
});

