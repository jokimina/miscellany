arr = ['xxx-xx', 'xxx-xx', 'xxxx', 'xxxxxxxxxx']
stopRun = false;
function sleep(ms) {
	return new Promise(resolve => setTimeout(resolve, ms));
}
run = async () => {
	let count = 0;
	for(let i =0;i <arr.length;i++){
	    if (stopRun) return;
		let url = `https://code.aliyun.com/groups/${arr[i]}/group_members`;
		let win = window.open(url);
	    var element = win.document.createElement('script');
		element.type='text/javascript';
		element.innerHTML = `
			topEle = $('.content-list .group_member');
			$('button', topEle).click();
			$.each(topEle, (k, v) => /xiaodong/.test($('.list-item-name a', v)[0].innerText) || $('[name="group_member[access_level]"]', v).val(20));
			$('.prepend-top-10 .btn').click();
		`
		setTimeout(function () {
			win.document.body.appendChild(element);
		}, 5000);
		await sleep(3000);
	}
}

run()
