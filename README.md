<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"><title>Lydovar</title>
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<style>
:root{--ui:rgba(20,20,24,.7);--fg:#fff}
html,body{height:100%;margin:0;overflow:hidden;background:#9fc7f2;font-family:system-ui,sans-serif}
canvas{display:block;touch-action:none}
#ui{position:fixed;left:0;top:0;padding:calc(10px + env(safe-area-inset-top,0px)) 12px 10px;color:var(--fg);background:var(--ui);border-radius:0 0 10px 0;font-size:13px;line-height:1.5}
#ui b{font-size:18px;letter-spacing:2px}
#ui input{width:130px;padding:3px 6px;border-radius:4px;border:0}
#xh{position:fixed;left:50%;top:50%;width:8px;height:8px;margin:-4px;border:2px solid #fff;border-radius:50%;box-shadow:0 0 0 1px #0008;display:none;pointer-events:none}
#fx{position:fixed;inset:0;pointer-events:none;opacity:0;background:repeating-conic-gradient(from 0deg at 50% 55%,rgba(255,255,255,0) 0 5deg,rgba(255,255,255,.5) 5.4deg 6deg);-webkit-mask:radial-gradient(circle at 50% 55%,transparent 40%,#000 90%);mask:radial-gradient(circle at 50% 55%,transparent 40%,#000 90%)}
#pad{position:fixed;right:16px;bottom:calc(16px + env(safe-area-inset-bottom,0px));display:grid;grid-template-columns:repeat(4,52px);gap:6px}
#pad button{height:52px;border:0;border-radius:10px;background:var(--ui);color:#fff;font-size:18px}
@media (hover:hover){#pad{display:none}}
</style></head><body>
<div id="ui"><b>LYDOVAR</b><br>WASD: walk · Space: jump<br><b style="font-size:13px;letter-spacing:0">Shift</b>: shift lock · Hold <b style="font-size:13px;letter-spacing:0">E</b>: sprint<br>Drag: look · Scroll: zoom<br>Name: <input id="nm" value="Player1" maxlength="20"></div>
<div id="xh"></div><div id="fx"></div>
<div id="pad"><button data-k="e">⚡</button><button data-k="w">▲</button><button data-k=" ">⤒</button><button id="lk">🔒</button><span></span><button data-k="a">◀</button><button data-k="s">▼</button><button data-k="d">▶</button></div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
<script>
const HOR=0x9fc7f2,S=400;
const scene=new THREE.Scene();scene.fog=new THREE.Fog(HOR,90,300);
const cam=new THREE.PerspectiveCamera(70,innerWidth/innerHeight,.1,1000);
const ren=new THREE.WebGLRenderer({antialias:true});ren.setSize(innerWidth,innerHeight);ren.setPixelRatio(Math.min(devicePixelRatio,2));
ren.shadowMap.enabled=true;ren.shadowMap.type=THREE.PCFSoftShadowMap;document.body.prepend(ren.domElement);
const T=(w,h,fn)=>{const c=document.createElement('canvas');c.width=w;c.height=h;fn(c.getContext('2d'),w,h);const t=new THREE.CanvasTexture(c);t.anisotropy=4;return t};
const mat=m=>new THREE.MeshLambertMaterial(m),B=(w,h,d)=>new THREE.BoxGeometry(w,h,d);

// Lighting + realistic sky
scene.add(new THREE.HemisphereLight(0xcfe4ff,0x6a6a6a,.75));
const sunDir=new THREE.Vector3(.55,.5,.35).normalize();
const sun=new THREE.DirectionalLight(0xfff0d8,1.05);sun.castShadow=true;
Object.assign(sun.shadow.camera,{left:-45,right:45,top:45,bottom:-45,far:200});sun.shadow.mapSize.set(2048,2048);sun.shadow.bias=-.0004;
scene.add(sun,sun.target);
const sky=new THREE.Mesh(new THREE.SphereGeometry(450,32,16),new THREE.ShaderMaterial({side:THREE.BackSide,depthWrite:false,fog:false,uniforms:{sd:{value:sunDir}},
vertexShader:'varying vec3 d;void main(){d=normalize(position);gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.);}',
fragmentShader:'varying vec3 d;uniform vec3 sd;void main(){float h=max(d.y,0.);vec3 c=mix(vec3(.62,.78,.95),vec3(.12,.34,.8),pow(h,.5));float s=max(dot(d,sd),0.);c+=vec3(1.,.8,.5)*(pow(s,1200.)*5.+pow(s,14.)*.3+pow(s,3.)*.1);c=mix(c,vec3(.62,.78,.95),smoothstep(0.,-.15,d.y));gl_FragColor=vec4(c,1.);}'}));
sky.renderOrder=-1;scene.add(sky);
const cloudT=T(256,128,(g)=>{for(let i=0;i<24;i++){const x=40+Math.random()*176,y=44+Math.random()*40,r=16+Math.random()*26,q=g.createRadialGradient(x,y,0,x,y,r);q.addColorStop(0,'rgba(255,255,255,.6)');q.addColorStop(1,'rgba(255,255,255,0)');g.fillStyle=q;g.fillRect(0,0,256,128)}});
const clouds=[];for(let i=0;i<16;i++){const s=new THREE.Sprite(new THREE.SpriteMaterial({map:cloudT,transparent:true,depthWrite:false,fog:false}));
 s.scale.set(110+Math.random()*90,45+Math.random()*25,1);s.position.set((Math.random()-.5)*700,110+Math.random()*60,(Math.random()-.5)*700);scene.add(s);clouds.push(s)}

// Textures
const gt=T(64,64,(g)=>{g.fillStyle='#62666c';g.fillRect(0,0,64,64);g.fillStyle='#74787f';g.fillRect(2,2,60,60);
 for(const [x,y] of [[16,16],[48,16],[16,48],[48,48]]){g.fillStyle='#5c6066';g.beginPath();g.arc(x+1,y+2,8,0,7);g.fill();g.fillStyle='#8a8e95';g.beginPath();g.arc(x,y,8,0,7);g.fill();g.fillStyle='#7d8188';g.beginPath();g.arc(x,y,5,0,7);g.fill()}});
gt.wrapS=gt.wrapT=THREE.RepeatWrapping;gt.repeat.set(S/8,S/8);gt.magFilter=THREE.NearestFilter;
const wood=T(128,128,(g)=>{g.fillStyle='#b07c3e';g.fillRect(0,0,128,128);g.strokeStyle='#8a5c28';g.lineWidth=2;for(let i=1;i<4;i++){g.beginPath();g.moveTo(0,i*32);g.lineTo(128,i*32);g.stroke()}
 for(let i=0;i<60;i++){g.strokeStyle='rgba(90,55,20,.25)';g.beginPath();const y=Math.random()*128;g.moveTo(Math.random()*128,y);g.lineTo(Math.random()*128,y+2);g.stroke()}
 g.strokeStyle='#5a3a18';g.lineWidth=12;g.strokeRect(6,6,116,116);g.lineWidth=8;g.beginPath();g.moveTo(10,10);g.lineTo(118,118);g.moveTo(118,10);g.lineTo(10,118);g.stroke()});
const conc=T(64,64,(g)=>{g.fillStyle='#8d9198';g.fillRect(0,0,64,64);for(let i=0;i<220;i++){g.fillStyle=`rgba(${Math.random()<.5?'255,255,255':'0,0,0'},.07)`;g.fillRect(Math.random()*64,Math.random()*64,3,3)}g.strokeStyle='#6c7077';g.lineWidth=2;g.strokeRect(1,1,62,62)});
const hazard=T(32,128,(g,w,h)=>{for(let i=0;i<8;i++){g.fillStyle=i%2?'#fff':'#ff7a00';g.fillRect(0,i*16,w,16)}});
const padT=T(64,64,(g)=>{g.fillStyle='#0b3d1c';g.fillRect(0,0,64,64);g.strokeStyle='#4dff88';g.lineWidth=7;g.lineCap='round';g.lineJoin='round';for(const y of [44,26,8]){g.beginPath();g.moveTo(14,y+10);g.lineTo(32,y-4);g.lineTo(50,y+10);g.stroke()}});

// Physics world
const all=[],G=-75;
function addBox(w,h,d,x,y,z,m,o={}){const me=new THREE.Mesh(B(w,h,d),m);me.position.set(x,y+h/2,z);me.castShadow=me.receiveShadow=true;scene.add(me);
 const b={c:me.position,h:{x:w/2,y:h/2,z:d/2},v:new THREE.Vector3(),dyn:!!o.dyn,m:1,pad:!!o.pad};all.push(b);return b}
const pb={c:new THREE.Vector3(0,3,0),h:{x:.9,y:2.6,z:.7},v:new THREE.Vector3(),dyn:true,isP:true,m:3,step:true,ground:false};all.unshift(pb);
const cm=mat({map:wood}),sm0=mat({map:conc});
addBox(12,.4,12,0,0,0,mat({color:0x3c4047}));
for(let i=0;i<5;i++)addBox(14,i+1,4,0,0,-24-i*4,sm0);
addBox(22,6,22,0,0,-54,sm0);
addBox(7,.5,7,-22,0,-8,new THREE.MeshBasicMaterial({map:padT,color:0xaaffcc}),{pad:true});
for(const [x,z] of [[-45,-45],[45,-45],[-45,45],[45,45]])addBox(5,30,5,x,0,z,mat({map:hazard}));
const crate=(x,y,z)=>addBox(3,3,3,x,y,z,cm,{dyn:true});
[-3.1,0,3.1].forEach(z=>crate(24,0,z));[-1.55,1.55].forEach(z=>crate(24,3.05,z));crate(24,6.1,0);
[[10,0,14],[-14,0,18],[16,0,-16],[-6,0,22],[30,0,20],[-30,0,-20]].forEach(p=>crate(...p));
// Baseplate
const base=new THREE.Mesh(B(S,2,S),mat({map:gt}));base.position.y=-1;base.receiveShadow=true;scene.add(base);

// Avatar (R6) with user face
const faceC=document.createElement('canvas');faceC.width=faceC.height=256;const fg=faceC.getContext('2d');fg.fillStyle='#fff';fg.fillRect(0,0,256,256);
const faceT=new THREE.CanvasTexture(faceC);faceT.anisotropy=4;
const img=new Image();img.onload=()=>{fg.drawImage(img,0,0,256,256);faceT.needsUpdate=true};img.src='data:image/png;base64,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';
const ORANGE='#ff7a00',SILVER='#dfe6ea';
const vest=(f)=>T(128,128,(g,w,h)=>{g.fillStyle=ORANGE;g.fillRect(0,0,w,h);g.fillStyle=SILVER;g.fillRect(w*.2,0,w*.12,h);g.fillRect(w*.68,0,w*.12,h);g.fillRect(0,h*.68,w,h*.1);if(f){g.fillStyle='#8a4300';g.fillRect(w*.49,0,w*.02,h*.68)}});
const sleeve=T(64,128,(g,w,h)=>{g.fillStyle='#f4f4f4';g.fillRect(0,0,w,h);g.fillStyle=ORANGE;g.fillRect(0,0,w,h*.48);g.fillStyle=SILVER;g.fillRect(0,h*.36,w,h*.07)});
const pants=T(64,128,(g,w,h)=>{g.fillStyle='#2f343d';g.fillRect(0,0,w,h);g.fillStyle=SILVER;g.fillRect(0,h*.62,w,h*.06);g.fillStyle='#14171c';g.fillRect(0,h*.88,w,h*.12)});
const part=(geo,m,y)=>{const p=new THREE.Mesh(geo,m);p.position.y=y;p.castShadow=true;return p};
const player=new THREE.Group(),body=new THREE.Group();player.add(body);
const hm=Array(6).fill(0).map(()=>mat({color:0xffffff}));hm[4]=mat({map:faceT});
body.add(part(B(1.2,1.2,1.2),hm,4.6));
const vs=mat({map:vest(false)}),vf=mat({map:vest(true)});body.add(part(B(2,2,1),[vs,vs,vs,vs,vf,vs],3));
function limb(x,y,w,m){const p=new THREE.Group();p.position.set(x,y,0);p.add(part(B(w,2,1),m,-1));body.add(p);return p}
const sm=mat({map:sleeve}),pm=mat({map:pants});
const armL=limb(-1.5,4,1,sm),armR=limb(1.5,4,1,sm),legL=limb(-.5,2,1,pm),legR=limb(.5,2,1,pm);
const cone=new THREE.Group();
const ct=T(64,128,(g,w,h)=>{g.fillStyle=ORANGE;g.fillRect(0,0,w,h);g.fillStyle='#fff';g.fillRect(0,h*.3,w,h*.16);g.fillRect(0,h*.58,w,h*.16)});
cone.add(part(new THREE.CylinderGeometry(.14,.55,1.7,24,1,true),mat({map:ct,side:THREE.DoubleSide}),.95));
cone.add(part(B(1.25,.12,1.25),mat({color:0xff7a00}),.06));cone.position.y=5.2;body.add(cone);
let tag;function setTag(t){if(tag){player.remove(tag);tag.material.map.dispose()}
 tag=new THREE.Sprite(new THREE.SpriteMaterial({map:T(512,96,(x)=>{x.font='bold 56px sans-serif';x.textAlign='center';x.lineWidth=8;x.strokeStyle='#000';x.fillStyle='#fff';x.strokeText(t,256,64);x.fillText(t,256,64)}),depthTest:false}));
 tag.scale.set(6,1.1,1);tag.position.y=8.1;player.add(tag)}
setTag('Player1');nm.oninput=()=>setTag(nm.value||'Player');scene.add(player);

// Particles
const dotT=T(64,64,(g)=>{const q=g.createRadialGradient(32,32,0,32,32,32);q.addColorStop(0,'rgba(255,255,255,.95)');q.addColorStop(1,'rgba(255,255,255,0)');g.fillStyle=q;g.fillRect(0,0,64,64)});
const parts=[];for(let i=0;i<110;i++){const s=new THREE.Sprite(new THREE.SpriteMaterial({map:dotT,transparent:true,depthWrite:false}));s.visible=false;scene.add(s);parts.push({s,life:0,max:1,v:new THREE.Vector3(),g:0,size:1,grow:0,op:1})}
function emit(x,y,z,vx,vy,vz,size,life,col,add,grow=1,g=0,op=.8){const p=parts.find(p=>p.life<=0);if(!p)return;
 p.life=p.max=life;p.v.set(vx,vy,vz);p.size=size;p.grow=grow;p.g=g;p.op=op;p.s.position.set(x,y,z);p.s.material.color.set(col);p.s.material.blending=add?THREE.AdditiveBlending:THREE.NormalBlending;p.s.visible=true}
const rnd=(a)=>(Math.random()-.5)*a;
function bounceFx(){const p=pb.c;for(let i=0;i<18;i++){const a=i/18*6.28;emit(p.x,p.y-2.4,p.z,Math.cos(a)*9,3+Math.random()*6,Math.sin(a)*9,1.2,.7,0x66ffaa,true,.4,-10,1)}}
function dustBurst(n,sp){const p=pb.c;for(let i=0;i<n;i++){const a=i/n*6.28;emit(p.x,p.y-2.4,p.z,Math.cos(a)*sp,1.2,Math.sin(a)*sp,1.6,.7,0xc2c6cc,false,2.2)}}

// Input
const keys={};let lock=false;const xh=document.getElementById('xh'),fx=document.getElementById('fx');
function setLock(v){lock=v;xh.style.display=v?'block':'none';
 if(v){try{const r=ren.domElement.requestPointerLock();if(r&&r.catch)r.catch(()=>{})}catch(e){}}else if(document.pointerLockElement)document.exitPointerLock()}
document.addEventListener('pointerlockchange',()=>{if(!document.pointerLockElement&&lock)setLock(false)});
addEventListener('keydown',e=>{if(e.target.tagName==='INPUT')return;if(e.key==='Shift'&&!e.repeat)setLock(!lock);else keys[e.key.toLowerCase()]=1;if(e.key===' ')e.preventDefault()});
addEventListener('keyup',e=>{if(e.key!=='Shift')keys[e.key.toLowerCase()]=0});
document.querySelectorAll('#pad button[data-k]').forEach(b=>{const k=b.dataset.k;b.addEventListener('pointerdown',e=>{keys[k]=1;e.preventDefault()});['pointerup','pointerleave'].forEach(v=>b.addEventListener(v,()=>keys[k]=0))});
document.getElementById('lk').addEventListener('click',()=>setLock(!lock));
let yaw=0,pitch=.35,dist=18,tyaw=0,tpitch=.35,tdist=18,tx=0,ty=0;
const look=(dx,dy)=>{tyaw-=dx*.006;tpitch=Math.max(-.3,Math.min(1.4,tpitch+dy*.006))};
document.addEventListener('mousemove',e=>{if(document.pointerLockElement||e.buttons)look(e.movementX,e.movementY)});
ren.domElement.addEventListener('touchstart',e=>{tx=e.touches[0].clientX;ty=e.touches[0].clientY},{passive:true});
ren.domElement.addEventListener('touchmove',e=>{const t=e.touches[0];look(t.clientX-tx,t.clientY-ty);tx=t.clientX;ty=t.clientY},{passive:true});
addEventListener('wheel',e=>{tdist=Math.max(6,Math.min(50,tdist+e.deltaY*.02))});
addEventListener('resize',()=>{cam.aspect=innerWidth/innerHeight;cam.updateProjectionMatrix();ren.setSize(innerWidth,innerHeight)});

// Collision resolve
function resolve(A,Bd){
 const dx=A.c.x-Bd.c.x,dy=A.c.y-Bd.c.y,dz=A.c.z-Bd.c.z;
 const ox=A.h.x+Bd.h.x-Math.abs(dx),oy=A.h.y+Bd.h.y-Math.abs(dy),oz=A.h.z+Bd.h.z-Math.abs(dz);
 if(ox<=0||oy<=0||oz<=0)return;
 const ax=oy<=ox&&oy<=oz?'y':ox<=oz?'x':'z';
 if(A.step&&ax!=='y'&&!Bd.dyn){const lift=(Bd.c.y+Bd.h.y)-(A.c.y-A.h.y);
  if(lift>0&&lift<=1.15){A.c.y+=lift;A.v.y=Bd.pad?55:Math.max(A.v.y,0);if(Bd.pad)bounceFx();A.ground=true;return}}
 if(ax==='y'){const up=dy>0;
  if(!Bd.dyn){A.c.y+=up?oy:-oy;
   if(up){if(Bd.pad&&A.isP){A.v.y=55;bounceFx()}else A.v.y=(!A.isP&&A.v.y<-8)?-A.v.y*.25:Math.max(A.v.y,0);A.ground=true}else A.v.y=Math.min(A.v.y,0)}
  else{const U=up?A:Bd;U.c.y+=oy;U.v.y=Math.max(U.v.y,0);U.ground=true}
 }else{const n=Math.sign(ax==='x'?dx:dz)||1,o=ax==='x'?ox:oz;
  if(!Bd.dyn){A.c[ax]+=n*o;A.v[ax]=0}
  else{const tm=A.m+Bd.m;A.c[ax]+=n*o*Bd.m/tm;Bd.c[ax]-=n*o*A.m/tm;const nv=(A.v[ax]*A.m+Bd.v[ax]*Bd.m)/tm;if(!A.isP)A.v[ax]=nv;if(!Bd.isP)Bd.v[ax]=nv}}
}

// Main loop
const damp=(k,dt)=>1-Math.exp(-k*dt);
let t=0,sq=0,lean=0,sh=0,fov=70,fxo=0,lastG=0,wasG=true,dT=0,sT=0;
const sw={aL:0,aR:0,lL:0,lR:0},look3=new THREE.Vector3(0,3.5,0),want=new THREE.Vector3();
let last=performance.now();
function tick(now){requestAnimationFrame(tick);const dt=Math.min((now-last)/1000,.05);last=now;const ts=now/1000;
 const fw=(keys.w||keys.arrowup?1:0)-(keys.s||keys.arrowdown?1:0),rt=(keys.d||keys.arrowright?1:0)-(keys.a||keys.arrowleft?1:0);
 let dx=-Math.sin(yaw)*fw+Math.cos(yaw)*rt,dz=-Math.cos(yaw)*fw-Math.sin(yaw)*rt;const len=Math.hypot(dx,dz);if(len){dx/=len;dz/=len}
 const sprint=!!keys.e&&len>0,SPEED=sprint?30:16;
 const a=damp(pb.ground?(len?10:14):4,dt);pb.v.x+=(dx*SPEED-pb.v.x)*a;pb.v.z+=(dz*SPEED-pb.v.z)*a;
 if(pb.ground)lastG=ts;
 if(keys[' ']&&ts-lastG<.1){pb.v.y=25;lastG=-9;dustBurst(6,4)}
 const vyB=pb.v.y,gB=pb.ground,N=3,h=dt/N;
 for(let s=0;s<N;s++){
  for(const b of all)if(b.dyn){b.ground=false;b.v.y+=G*h;b.c.addScaledVector(b.v,h)}
  for(let i=0;i<all.length;i++){if(!all[i].dyn)continue;for(let j=0;j<all.length;j++){if(j===i||(all[j].dyn&&j<i))continue;resolve(all[i],all[j])}}
  for(const b of all)if(b.dyn){const bt=b.c.y-b.h.y;if(bt<0){b.c.y-=bt;b.v.y=(!b.isP&&b.v.y<-8)?-b.v.y*.25:Math.max(b.v.y,0);b.ground=true}
   b.c.x=Math.max(-S/2+2,Math.min(S/2-2,b.c.x));b.c.z=Math.max(-S/2+2,Math.min(S/2-2,b.c.z));
   if(!b.isP){const f=Math.exp(-(b.ground?3:.3)*h);b.v.x*=f;b.v.z*=f}}
 }
 player.position.set(pb.c.x,pb.c.y-2.6,pb.c.z);
 const spd=Math.hypot(pb.v.x,pb.v.z),p=player.position;
 if(pb.ground&&!gB&&vyB<-14){sq=Math.min(.3,-vyB*.008);dustBurst(10,6)}
 // facing
 let tr=null;if(lock)tr=yaw+Math.PI;else if(spd>.8&&len)tr=Math.atan2(pb.v.x,pb.v.z);
 if(tr!==null){let d=tr-player.rotation.y;d=Math.atan2(Math.sin(d),Math.cos(d));player.rotation.y+=d*damp(14,dt)}
 // animation
 t+=dt*spd*(sprint?.55:.75);const air=!pb.ground,k=damp(20,dt),run=Math.min(1,spd/16);
 let aL,aR,lL,lR;
 if(air){aL=aR=-2.7;lL=.5;lR=-.5}
 else{const A=(sprint?1.35:.9)*run,s=Math.sin(t);const idle=Math.sin(ts*2)*.05*(1-run);aL=s*A+idle;aR=-s*A-idle;lL=-s*A;lR=s*A}
 sw.aL+=(aL-sw.aL)*k;sw.aR+=(aR-sw.aR)*k;sw.lL+=(lL-sw.lL)*k;sw.lR+=(lR-sw.lR)*k;
 armL.rotation.x=sw.aL;armR.rotation.x=sw.aR;legL.rotation.x=sw.lL;legR.rotation.x=sw.lR;
 armL.rotation.z=-.05-(air?.3:0);armR.rotation.z=.05+(air?.3:0);
 lean+=((sprint?.32:.1)*run-lean)*damp(8,dt);sq*=Math.exp(-9*dt);
 body.rotation.x=lean;body.scale.set(1+sq*.5,1-sq,1+sq*.5);
 cone.rotation.x=-spd*.008+(air?-pb.v.y*.006:0);cone.rotation.z=Math.sin(t*2)*.04*run;
 // effects
 dT-=dt;sT-=dt;
 if(pb.ground&&spd>7&&dT<=0){dT=sprint?.04:.08;emit(p.x-pb.v.x*.05+rnd(.8),p.y+.3,p.z-pb.v.z*.05+rnd(.8),rnd(2)-pb.v.x*.1,.8+Math.random(),rnd(2)-pb.v.z*.1,sprint?1.7:1.2,.6,0xbfc3c9,false,2.2,0,.55)}
 if(sprint&&spd>12&&sT<=0){sT=.03;emit(p.x+rnd(1),p.y+.3,p.z+rnd(1),-pb.v.x*.12,1+Math.random()*2,-pb.v.z*.12,.7,.35,0xff9a30,true,-.6,-4,1);
  emit(p.x,p.y+2.6,p.z,0,0,0,2.6,.28,0xffd9a0,true,-.9,0,.35)}
 fxo+=((sprint&&spd>14?.55:0)-fxo)*damp(6,dt);fx.style.opacity=fxo;
 for(const q of parts){if(q.life<=0)continue;q.life-=dt;if(q.life<=0){q.s.visible=false;continue}
  q.s.position.addScaledVector(q.v,dt);q.v.y+=q.g*dt;const f=q.life/q.max;q.s.scale.setScalar(Math.max(.05,q.size*(1+q.grow*(1-f))));q.s.material.opacity=f*q.op}
 // world
 for(const c of clouds){c.position.x+=dt*2.5;if(c.position.x>360)c.position.x=-360}
 // camera (shift lock = over-the-shoulder)
 const kc=damp(14,dt);yaw+=(tyaw-yaw)*kc;pitch+=(tpitch-pitch)*kc;dist+=(tdist-dist)*kc;
 sh+=((lock?2.6:0)-sh)*damp(10,dt);
 const rx=Math.cos(yaw)*sh,rz=-Math.sin(yaw)*sh;
 want.set(p.x+Math.sin(yaw)*Math.cos(pitch)*dist+rx,Math.max(1.5,p.y+4+Math.sin(pitch)*dist),p.z+Math.cos(yaw)*Math.cos(pitch)*dist+rz);
 cam.position.lerp(want,damp(20,dt));
 look3.lerp(want.set(p.x+rx,p.y+3.5,p.z+rz),damp(20,dt));cam.lookAt(look3);
 fov+=((sprint&&spd>14?84:70)-fov)*damp(5,dt);cam.fov=fov;cam.updateProjectionMatrix();
 sky.position.copy(cam.position);
 sun.position.set(p.x+sunDir.x*70,sunDir.y*70,p.z+sunDir.z*70);sun.target.position.copy(p);
 ren.render(scene,cam)}
requestAnimationFrame(tick);
</script></body></html>
