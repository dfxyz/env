// ==UserScript==
// @name         Noto SC Font Replacer
// @namespace    http://tampermonkey.net/
// @version      2025-03-06
// @description  强制使用Noto Sans SC、Noto Serif SC、Fira Noto SC等字体
// @author       DF_XYZ (dfxyz1@gmail.com)
// @match        *://*/*
// @grant        none
// ==/UserScript==

'use strict';

const css = `
code, pre {
    font-family: 'Fira Noto SC', monospace !important;
}
@font-face {
    font-family: 'sans-serif';
    src: local('Noto Sans SC');
}
@font-face {
    font-family: 'serif';
    src: local('Noto Serif SC');
}
@font-face {
    font-family: 'monospace';
    src: local('Fira Noto SC');
}
@font-face {
    font-family: '宋体';
    src: local('Noto Sans SC');
}
@font-face {
    font-family: '新宋体';
    src: local('Noto Sans SC');
}
@font-face {
    font-family: '微软雅黑';
    src: local('Noto Sans SC');
}
@font-face {
    font-family: 'SimSun';
    src: local('Noto Sans SC');
}
@font-face {
    font-family: 'NSimSun';
    src: local('Noto Sans SC');
}
@font-face {
    font-family: 'Microsoft YaHei';
    src: local('Noto Sans SC');
}
@font-face {
    font-family: 'Microsoft YaHei UI';
    src: local('Noto Sans SC');
}
@font-face {
    font-family: 'ＭＳ Ｐゴシック';
    src: local('Noto Sans SC');
}
@font-face {
    font-family: 'MS PGothic';
    src: local('Noto Sans SC');
}
`;
const style = document.createElement('style');
style.textContent = css;
document.head.appendChild(style);
