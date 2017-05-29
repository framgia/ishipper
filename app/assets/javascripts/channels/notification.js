var owners = [];
var invoices = [];
var notifications = [];

if (getCookie("user_token_id")) {
  var channel = "NotificationChannel";
  App.notification = App.cable.subscriptions.create({
    channel: channel}, {
    received: function(data) {
      if (data.owner !== undefined) {
        owner = data.owner;
        invoice = data.invoice;
        notification = data.notification;

        owners.push(owner);
        invoices.push(invoice);
        notifications.push(notification);

      }
    },

    speak: function(data) {
      this.perform('speak', data);
    }
  });
}

function getCookie(name) {
  var value = "; " + document.cookie;
  var parts = value.split("; " + name + "=");
  if (parts.length == 2) return parts.pop().split(";").shift();
}

function convertNotification(owner, invoice, notification) {
  message = I18n.t("notifications.web." + notification.status, {user_name: owner.name, invoice_name: invoice.name});
  html = '<div class="shop_invoice_row" id="' + notification.invoice_id + '">';
  html += '<li class="nht-notification notification-' + notification.id + ' false-notification">';
  html += '<span class="col-md-2 col-lg-2 nht-notification-avatar">';
  html += '<img src="" id="avatar-' + notification.id + '" class="img-responsive nht-avatar">';
  html += '<div class="clearfix"></div></span>';
  html += '<span class="col-md-10 col-lg-10 nht-notification-content">';
  html += '<div class="content">' + message + '</div>';
  html += '<div class="small">' + jQuery.timeago(notification.created_at) + '</div></span>';
  html += '<div class="clearfix"></div></li><div class="clearfix"></div></div>';
  return html;
}

function bind_for_loading_more_notification() {
  var notifications_per_request = 10
  var list_notification = $('.nht-noti-list .shop_invoice_row').size();
  $(".nht-noti-list").unbind("scroll").bind("scroll", function() {
    var url = $(".pagination .next a").attr("href");
    if (url && ($(".nht-noti-list").scrollTop() > (list_notification*75 - $('.nht-noti-list').height() - 1 ))) {
      $(".pagination .next a").trigger('click');
      $('.td-loadmore img').show();
      list_notification += notifications_per_request;
    }
  });
}

document.addEventListener("turbolinks:load", function() {

  if ($('.nht-notification-count').is(':visible')) {
    if($('.nht-notification-count')[0].innerText == '0') {
      $('.nht-notification-count').hide();
    } else {
      $('.nht-notifications').show();
    }
  }

  if($('.nht-notifications').length) {
    $('.nht-notifications').hide();
  }

  $('.nht-notification-icon i').on('click', function() {
    $(this).toggleClass('fa-globe-focus');
  });

  $('.nht-notification-icon i').on('click', function() {

    $('.dropdown-menu').slideUp(200);

    $('.nht-noti-list').niceScroll({
      cursorwidth: "10px",
      cursorcolor: "rgba(0, 0, 0, 0.4)",
      autohidemode: false,
      cursorminheight: 100,
      smoothscroll: true,
    });


    if (!$('.nht-notifications').is(":visible")) {
      $('.nht-notification-count').hide();
      if($('.nht-notification-count')[0].innerText != 0) {
        App.notification.speak({action_type: "unread_notification"});
      }

      $.each( notifications, function(index, value) {
        owner = owners[index];
        invoice = invoices[index];
        notification = notifications[index];
        html = convertNotification(owner, invoice, notification);
        $('.nht-noti-list').prepend(html);
        if (owner.avatar.url != null) {
          $('#avatar-' + notification.id)[0].src = owner.avatar.url;
        } else {
          $('#avatar-' + notification.id)[0].src = '../assets/profile.jpg';
        }
      });
      owners = [];
      invoices = [];
      notifications = [];
      $.ajax({
        url: '/shop/notifications',
        method: 'get',
        dataType: 'text'
      }).done(function(data){
        $('#td-notification-index').html(data);
        bind_for_loading_more_notification();
        $on_process = false;
      });
      $('.nht-up-arrow').show();
      $('.nht-notifications').show();
    } else {
      $('#td-notification-index').empty();
      $('.nht-up-arrow').hide();
      $('.nht-notifications').hide();
    }

  });

  $(document).on('click', '.nht-notification', function() {
    id = parseInt(this.className.split(' ')[1].split('-')[1]);
    App.notification.speak({action_type: "unread_notification", notification_id: id});
  });

  $('.false-notification').on('mouseover', function() {
    $(this).addClass('true-notification');
  });

  $('.false-notification').on('mouseout', function() {
    $(this).removeClass('true-notification');
  });
});
