$(function(){
    for(i=1; i<200; i++){
        $('#page').append('<option value="' + i + '">' + i + '</option>');
    }
    var id = getUrlParam('id');
    if (id == undefined || id == null || id == "")
        return;
    var page = new Number(getUrlParam('page'));
    $('#img-container').html('');
    for(i=1; i <= page; i++){
        $('#img-container').append('<img src="/content/images/mm/' + id + '-' + i + '.jpg"><br/>');
    }
});

$('.summit').click(function(){
    var type = $('#type').val();
    var page = $('#page').val();
    var id = new Number($('#type option:selected').data('id'));
    var url = "http://www.mm131.com/" + type;
    if (page > 1)
        url = url + "/list_" + id + "_" + page + ".html";
    $('#tip').html('请求中...');
    $.ajax({
        url: "/spider?key=" +url,
        success: function(data){
            if (data == false || data.length == 0){
                $('#tip').html('无内容, 请重试');
                return;
            }
            $('#img-container').html('');
            for(i in data){
                $('#img-container').append('<a target="_blank" href="/?id=' + i + '&page=' + data[i] +'"><img src="/content/images/mm/' + i + '-1.jpg"><br/></a>');
            }
            $('#tip').html('请求完成, 点击图片查看详情');
        }
    });
});

function getUrlParam(name) {
    var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)"); //构造一个含有目标参数的正则表达式对象
    var r = window.location.search.substr(1).match(reg);  //匹配目标参数
    if (r != null) return unescape(r[2]); return null; //返回参数值
}