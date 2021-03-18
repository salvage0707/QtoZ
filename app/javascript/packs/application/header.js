$(() => {
  // ヘッダーのユーザーメニュー切り替え
  $('#user-menu-button').on('click', () => {
    $('#user-menu').toggleClass('hidden');
  });
});