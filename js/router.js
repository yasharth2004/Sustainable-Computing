export const router={parse(){const [path,id]=location.hash.replace(/^#\/?/,'').split('/');return{path:path||'home',id}},go(path){location.hash=`#/${path}`}};
