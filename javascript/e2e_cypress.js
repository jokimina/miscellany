/// <reference types="Cypress" />

Cypress.Cookies.defaults({
  whitelist: /session/i
})
Cypress.Cookies.debug(true)
Cypress.LocalStorage.clear = function (keys, ls, rs) {
  if (keys) {
    return clear.apply(this, arguments)
  }
}

function fireEvent(element, eventName){
  element = element.get(0)
  event = document.createEvent('Events')
  event.initEvent(eventName, true, false)
  element.dispatchEvent(event)
}

context('sc-demo-web', () => {

    var currentLoanId = ''

    // beforeEach(() => {
    //     cy.viewport('iphone-6+')
    // })

    before(() => {
      // 登录demo 白名单直接验证码登陆
      cy.server()
      // cy.route('/rest/anon/**').as('getAnon')
      cy.visit('/')
        .url().should('include','/#/user/login')
        .get('#phone').type(Cypress.env('phone'))
        .get('#otpCode').type(Cypress.env('captcha'))
        .get('.form_custom > .form_btn > button').click().wait(5000)
      // cy.wait('@getAnon')
        // .url().should('include', '/#/loan')

      // 登录管理后台
      cy.visit(Cypress.env('backendUrl') + '/admin')
        .get('[id="admin"]',{timeout: 30000}).type(Cypress.env('backendUser'))
        .get('[id="password"]').type(Cypress.env('backendPass'))
        .get('[type="submit"]').click()
        .get('.app-list ul li', {timeout: 30000}).should(($li) => {
          expect($li).to.have.length.above(0)
        }).last().click({multiple: false}).wait(1000)
          .url().should('include', '/loanList')
    })

    it('借款状态检查', () => {
      // 到对应mars-h5后台检查借款状态
      cy.get('input[name="phone"]', {timeout: 30000}).type(Cypress.env('phone'))
        .get('.operation').click()
      cy.get('tbody', {timeout: 10000}).children("tr", {timeout: 10000}).should('have.length.gt', 0)
      // .children('td')
      cy.get('tbody tr').first().find('td', {timeout: 30000}).invoke('text')
        .then((text) => {
          // 取消存在的借款
          if (/Canceled|PaidOff|FinalRejected/.test(text) === false){
            // let loanid = text.match(/\w+_\w+/)[0]
            let loanid = text.slice(0,15)
            cy.log('存在订单: ' + loanid + " 尝试取消借款...")
            cy.visit(Cypress.env('backendUrl') + '/loanDetail/' + loanid)
              // 直接trigger在windows下正常, Electron Linux下会报错
              // .trigger('mouseover')
              .get('.actionButton', {timeout: 30000}).then(($e) => {
                fireEvent($e, 'mouseover')
              })
              .get('.ant-dropdown ul > li').last().click()
              .get('[name="gotoRemark"]').type(Cypress.env('remark'))
              .get('.ant-modal-content button.ant-btn-primary').click()
              .reload().wait(1000)
              .get('.loanDetail .status .value').invoke('text')
              .then((t)=>{
                cy.log('status: ' + t)
                // 打款状态只能先拒绝再取消
                if (/Rejected/.test(t) === true){
                  cy.log('处于打款中, Rejected后再Canceled...')
                  cy.get('.actionButton', {timeout: 30000}).then(($e) => {
                      fireEvent($e, 'mouseover')
                    })
                    .get('.ant-dropdown ul > li').last().click()
                    .get('[name="gotoRemark"]').type(Cypress.env('remark'))
                    .get('.ant-modal-content button.ant-btn-primary').click()  
                }
              })
              .reload().wait(1000)
              // 刷新按钮容易失效  直接刷新页面
            // cy.visit(Cypress.env('backendUrl') + '/loanDetail/' + loanid)
              .get('.loanDetail .status .value', ).invoke('text').should('equal', 'Canceled')
          }
        })
    })

    // it('发送验证码', ()=> {
      // cy.request({
          // method: 'POST',
          // url: '/rest/anon/sms',
          // body: {"phone": phoneNumber}
      // }).then((resp) => {
          // assert.isAtMost(resp.status, 400)
          // if (resp.status === 200){
              // expect(resp.body).to.have.property('otpCodeToken')
          // }
      // })
      // cy.get('[id="phone"]').type(phoneNumber)
      // cy.get('.captcha-btn').click()
    // })
 
    // it('账号注册&&账号登录', () => {
        // cy.visit('/#/login/password')
          // .get('[id="username"]').type(username)
          // .get('#password').type(password)
          // .get('button').click().url().should('include', '#/login/password')
          // .get('#username').type(username)
          // .get('#password').type(password)
          // .get('.form_custom > .form_btn > button').click()
          // .url().should('include', '#/loan')
    // })
    
    it('借款产品列表', () => {
        cy.visit('/#/loan').url().wait(1000)
          .should('include', '/#/loan')
          .get('.content', {timeout: 30000}).click()
    })

    // it('基本认证', () => {
    //     cy.visit('/#/cert/basic/identify').url().should('include', '#/cert/basic/identify')
    //       .get('.form_custom > :nth-child(1) > input').type(name)
    //       .get('.form_custom > :nth-child(2) > input').type(idNum)
    //       // .get(':nth-child(3) > span').invoke('text', '1980-01-01')
    //       .get(':nth-child(3) > span').click()
    //       .get('.mint-datetime-confirm').click()
    //       .get('.bg-themeColor').click().url().should('include', '/#/loanPage')
    // })

    it('借款提交', () => {
        cy.visit('/#/loanPage')
          // .get(':nth-child(2) > .bg-themeColor').click()
          .get('.save_btn button:visible').click().wait(3000)
          .url().should('include', '/#/cert/basicList')
          // .get('.mint-msgbox').then(($msgbox) => {
          // if (!$msgbox.css('display', 'none')){
            // cy.log(cy.get('.mint-msgbox-message').invoke('text'))  
          // }else{
            // cy.url().should('include', '/#/cert/basicList')
          // }
        // })
          // .catch((err) => {
            // cy.log("recorvery!" + err)
          // })
          // .url().should('include', '/#/cert/basicList')
    })

    it('认证列表', () => {
        // cy.visit('/#/cert/basicList')
        cy.get('.bg-themeColor').click().wait(3000)
          .url().should('include', '/#/loan/timeLine')
    })

    it('推送初审通过', () => {
        cy.visit(Cypress.env('backendUrl') + '/loanList')
          .get('input[name="phone"]', {timeout: 10000}).type(Cypress.env('phone'))
          .get('.operation', {timeout: 3000}).click()
          .get('tbody tr').first().find('td', {timeout: 3000}).invoke('text')
          .then((text) => { 
            if (/Submitted/.test(text) === true){
              currentLoanId = text.slice(0,15)
              cy.visit(Cypress.env('backendUrl') + '/loanDetail/' + currentLoanId)
              cy.get('.actionButton', {timeout: 3000}).then(($e) => {
                  fireEvent($e, 'mouseover')
                })
                .get('.ant-dropdown ul > li').first().click()
                .get('[name="gotoRemark"]').type(Cypress.env('remark'))
                .get('.ant-modal-content button.ant-btn-primary').click().wait(1000)
            }
          })
    })

    it('时间轴绑定银行卡', () => {
      cy.visit('/#/loan/timeLine')
        .get('.timeLine .save_btn button:visible', {timeout: 30000}).click()
        .url().should('include', '/#/bank/main')
        .get('.save_btn button:visible').click()
        .url().should('include', '/#/loan/timeLine')
    })

    it('时间轴签约', () => {
      cy.get('.timeLine .save_btn button', {timeout: 30000}).click()
        .url().should('include', '/#/loan/sign')
        .get('.sign .save_btn button', {timeout: 30000}).click()
        .url().should('include', '/#/loan/timeLine')
        // 线上自动打款很快, 等一下吧
        .wait(5000)
    })

    it('手动打款', () => {
      cy.visit(Cypress.env('backendUrl') + '/loanDetail/' + currentLoanId).wait(1000)
        .get('.loanDetail .status .value').invoke('text')
        .then((t)=>{
          cy.log('status: ' + t)
          if (/Confirmed/.test(t) === true){
          // if (/Funded/.test(t) === false){
            cy.get('.loanDetail .operation span button').click()
              .get('.funder #fundTime input').click().get('.ant-calendar-date-panel .ant-calendar-footer-btn').children('a').first().click()
              .get('.funder #status').click().get('ul[role="listbox"]').children('li').first().click()
              .get('.funder [id="exTradeNo"]').type(Cypress.env('remark'))
              .get('.funder [type="submit"]').click().wait(1000)
          }
        })
        // 手动刷新下
        // .get('.operation').children('button').first().click()
        .reload().wait(1000)
        .get('.loanDetail .status .value', {timeout: 10000}).invoke('text')
        .should('equal', 'Funded')
    })

    it('还款', () => {
        cy.visit('/#/loan').url().should('include', '/#/loan')
          .get('.content', {timeout: 30000}).click()
          .url().should('include', '/#/loan/repay')
          .get('.loan-repay button:visible').click()
          .url().should('include', '/#/repay')
          .get('.save_btn button:visible').click()
          .get('.loanSure-dialog .save_btn button:visible').click().wait(3000)
          .url().should('include', '/#/repay/wait?payStatus=Success')
          .get('.base').invoke('text').should('match', /成功|success/gi)

        // 去后台也查下状态
        cy.visit(Cypress.env('backendUrl') + '/loanDetail/' + currentLoanId)
          .get('.loanDetail .status .value', {timeout: 10000}).invoke('text')
          .should('equal', 'PaidOff')
    })
})
