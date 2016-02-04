/// <reference path="jquery-1.8.3.min.js" />
/// <reference path="tmpl.js" />
;(function () {

 moment.lang("zh-cn");
 template.helper('Date', Date);
 template.helper('moment', moment);
  
    var article = {
        isNight: 0,
        render: function (art) {

            if (!art.createDate) {
                art.createDate = parseInt((new Date()).getTime() / 1000);
            }

            var con = template("content-tmpl", {article:art});
            $("#content").html(con);

            if($(".highlight").length == 0) {
                hljs.initHighlighting();
            }
            window.location.href = "html://contentready";

            return 1;
        },

        setFontSize: function (sizeName) {

            $("body")[0].className = "body f" + sizeName;
            article.setNightMode(article.isNight);
            return 1;
        },

        setNightMode: function (isNight) {
            article.isNight = isNight;
            if (isNight) {
                $("body").addClass("night");
            }
            else {
                $("body").removeClass("night");
            }
            return 1;
        }
    };

    window.article = article;
    $(document).ready(function () {
        window.location.href = "html://docready";
    });
})();