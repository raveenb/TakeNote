function singlyConnect(service_name) {
    var url = 'https://api.singly.com/oauth/authorize?';
    var client_id = 'client_id=' + SinglySettings['client_id'] + '&';
    var callback='redirect_uri=http://project.tiggzi.com/view/'+_projectId+'/SinglySocialData.html&';
    var service = 'service='+service_name;     
    localStorage.setItem('singly_service', service_name);

    var finalURL = url + client_id + callback + service;

    // uncomment to see print the URL
    // console.log(finalURL);
    window.open(finalURL);
}