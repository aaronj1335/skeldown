exports.pipeline = function($, $head, $body) {
    var $h1 = $body.find('h1'),
        headerText = $h1.text().split(' -- ');

    $h1.html(headerText[0] + ' <small>' + headerText[1] + '</small>');

    $body.find('h2').each(function(i, el) {
        var text = $(el).text(),
            link = "["+text+"][]",
            id = text.toLowerCase().replace(/ /g, '-');
        $(el).attr('id', id).text(text.toLowerCase());
        $body.find('p:contains("'+text+'")').each(function(i, el) {
            var anchor = '<a href="#'+id+'">'+text.toLowerCase()+'</a>';
            $(el).html($(el).text().replace(link, anchor));
        });
    });
};
