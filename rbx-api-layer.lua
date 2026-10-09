-- Lardovar Engine: Roblox-compatible API layer
function print(...) local t={} for i=1,select('#',...) do t[#t+1]=tostring((select(i,...))) end __out(table.concat(t," ")) end
local TIME=0
local waiters,tweens={}, {}
local tok=setmetatable({},{__mode="k"})
local HUGE=1e18
local function typeOf(v)
  local mt=getmetatable(v)
  if type(v)=="table" and type(mt)=="table" and mt.__type then return mt.__type end
  return type(v)
end
typeof=typeOf
local resumeCo
local function sched(co,res)
  if coroutine.status(co)=="suspended" then
    waiters[#waiters+1]={co=co,wake=TIME+(tonumber(res) or 0),tok=tok[co] or 0,t0=TIME}
  end
end
resumeCo=function(co,...)
  tok[co]=(tok[co] or 0)+1
  local ok,res=coroutine.resume(co,...)
  if not ok then print("Error: "..tostring(res)) return end
  sched(co,res)
end
local function spawn(f,...) local co=coroutine.create(f) resumeCo(co,...) return co end
local function stepWaiters()
  local list=waiters waiters={}
  for _,w in ipairs(list) do
    if tok[w.co]==w.tok then
      if w.wake<=TIME then resumeCo(w.co,TIME-w.t0) else waiters[#waiters+1]=w end
    end
  end
end
wait=function(t) local r=coroutine.yield(t or 0.03) return r,TIME end
task={wait=wait,
 spawn=function(f,...) if type(f)=="thread" then resumeCo(f,...) return f end return spawn(f,...) end,
 defer=function(f,...) local a=table.pack(...) return spawn(function() wait(0) f(table.unpack(a,1,a.n)) end) end,
 delay=function(t,f,...) local a=table.pack(...) return spawn(function() wait(t) f(table.unpack(a,1,a.n)) end) end,
 cancel=function(co) tok[co]=(tok[co] or 0)+1 end}
function spawn_global(f,...) return task.spawn(f,...) end
_G.spawn=spawn_global
_G.delay=function(t,f) return task.delay(t,f) end
-- extra std functions
math.clamp=function(x,a,b) if x<a then return a elseif x>b then return b end return x end
math.sign=function(x) if x>0 then return 1 elseif x<0 then return -1 end return 0 end
math.round=function(x) return math.floor(x+0.5) end
math.lerp=function(a,b,t) return a+(b-a)*t end
table.find=function(t,v) for i,x in ipairs(t) do if x==v then return i end end return nil end
table.clone=function(t) local r={} for k,v in pairs(t) do r[k]=v end return r end
table.create=function(n,v) local r={} for i=1,n do r[i]=v end return r end
string.split=function(s,sep) local r={} sep=sep or "," local pat="(.-)"..sep:gsub("%p","%%%0") for p in (s..sep):gmatch(pat) do r[#r+1]=p end return r end
os={time=function() return math.floor(__time()) end,clock=function() return __time() end,date=function() return "" end}
tick=function() return __time() end
time=function() return TIME end
warn=function(...) print("[warn]",...) end
shared={}
-- signals
local SIG={__type="RBXScriptSignal"}
local SM={}
SIG.__index=SM
local function newSignal(onconn) return setmetatable({_l={},_oc=onconn},SIG) end
function SM.Connect(self,f)
  local c={Connected=true,_f=f}
  c.Disconnect=function() c.Connected=false for i,x in ipairs(self._l) do if x==c then table.remove(self._l,i) break end end end
  self._l[#self._l+1]=c
  if self._oc then self._oc() end
  return c
end
SM.connect=SM.Connect
function SM.Once(self,f) local c c=self:Connect(function(...) c.Disconnect() f(...) end) return c end
function SM.Wait(self) local co=coroutine.running() local c c=self:Connect(function(...) c.Disconnect() resumeCo(co,...) end) return coroutine.yield(HUGE) end
function SM.Fire(self,...)
  local a=table.pack(...) local l={}
  for i,c in ipairs(self._l) do l[i]=c end
  for _,c in ipairs(l) do if c.Connected then spawn(c._f,table.unpack(a,1,a.n)) end end
end
-- datatypes
local function mt(name,t) t.__type=name return t end
local V3=mt("Vector3",{})
V3.__index=function(t,k)
  if k=="Magnitude" then return math.sqrt(t.X*t.X+t.Y*t.Y+t.Z*t.Z)
  elseif k=="Unit" then local m=math.sqrt(t.X*t.X+t.Y*t.Y+t.Z*t.Z) if m>0 then return Vector3.new(t.X/m,t.Y/m,t.Z/m) end return t end
  return V3[k]
end
V3.__add=function(a,b) return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
V3.__sub=function(a,b) return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
V3.__mul=function(a,b) if type(a)=="number" then a,b=b,a end if type(b)=="number" then return Vector3.new(a.X*b,a.Y*b,a.Z*b) end return Vector3.new(a.X*b.X,a.Y*b.Y,a.Z*b.Z) end
V3.__div=function(a,b) if type(b)=="number" then return Vector3.new(a.X/b,a.Y/b,a.Z/b) end return Vector3.new(a.X/b.X,a.Y/b.Y,a.Z/b.Z) end
V3.__unm=function(a) return Vector3.new(-a.X,-a.Y,-a.Z) end
V3.__eq=function(a,b) return a.X==b.X and a.Y==b.Y and a.Z==b.Z end
V3.__tostring=function(a) return a.X..", "..a.Y..", "..a.Z end
V3.Dot=function(a,b) return a.X*b.X+a.Y*b.Y+a.Z*b.Z end
V3.Cross=function(a,b) return Vector3.new(a.Y*b.Z-a.Z*b.Y,a.Z*b.X-a.X*b.Z,a.X*b.Y-a.Y*b.X) end
V3.Lerp=function(a,b,t) return a+(b-a)*t end
Vector3={new=function(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},V3) end}
Vector3.zero=Vector3.new(0,0,0) Vector3.one=Vector3.new(1,1,1)
Vector3.xAxis=Vector3.new(1,0,0) Vector3.yAxis=Vector3.new(0,1,0) Vector3.zAxis=Vector3.new(0,0,1)
local V2=mt("Vector2",{})
V2.__index=function(t,k) if k=="Magnitude" then return math.sqrt(t.X*t.X+t.Y*t.Y) end return V2[k] end
V2.__add=function(a,b) return Vector2.new(a.X+b.X,a.Y+b.Y) end
V2.__sub=function(a,b) return Vector2.new(a.X-b.X,a.Y-b.Y) end
V2.__mul=function(a,b) if type(b)=="number" then return Vector2.new(a.X*b,a.Y*b) end return Vector2.new(a.X*b.X,a.Y*b.Y) end
V2.__tostring=function(a) return a.X..", "..a.Y end
Vector2={new=function(x,y) return setmetatable({X=x or 0,Y=y or 0},V2) end}
local C3=mt("Color3",{})
C3.__index=C3
C3.__eq=function(a,b) return a.R==b.R and a.G==b.G and a.B==b.B end
C3.__tostring=function(a) return a.R..", "..a.G..", "..a.B end
C3.Lerp=function(a,b,t) return Color3.new(a.R+(b.R-a.R)*t,a.G+(b.G-a.G)*t,a.B+(b.B-a.B)*t) end
Color3={new=function(r,g,b) return setmetatable({R=r or 0,G=g or 0,B=b or 0},C3) end,
 fromRGB=function(r,g,b) return Color3.new((r or 0)/255,(g or 0)/255,(b or 0)/255) end}
Color3.fromHSV=function(h,s,v)
  local i=math.floor(h*6) local f=h*6-i local p=v*(1-s) local q=v*(1-f*s) local t=v*(1-(1-f)*s) i=i%6
  if i==0 then return Color3.new(v,t,p) elseif i==1 then return Color3.new(q,v,p) elseif i==2 then return Color3.new(p,v,t)
  elseif i==3 then return Color3.new(p,q,v) elseif i==4 then return Color3.new(t,p,v) end return Color3.new(v,p,q)
end
local UD=mt("UDim",{}) UD.__index=UD
UDim={new=function(s,o) return setmetatable({Scale=s or 0,Offset=o or 0},UD) end}
local U2=mt("UDim2",{}) U2.__index=U2
UDim2={new=function(sx,ox,sy,oy) return setmetatable({X=UDim.new(sx,ox),Y=UDim.new(sy,oy)},U2) end}
UDim2.fromScale=function(x,y) return UDim2.new(x,0,y,0) end
UDim2.fromOffset=function(x,y) return UDim2.new(0,x,0,y) end
U2.__add=function(a,b) return UDim2.new(a.X.Scale+b.X.Scale,a.X.Offset+b.X.Offset,a.Y.Scale+b.Y.Scale,a.Y.Offset+b.Y.Offset) end
U2.__sub=function(a,b) return UDim2.new(a.X.Scale-b.X.Scale,a.X.Offset-b.X.Offset,a.Y.Scale-b.Y.Scale,a.Y.Offset-b.Y.Offset) end
U2.__tostring=function(a) return "{"..a.X.Scale..", "..a.X.Offset.."}, {"..a.Y.Scale..", "..a.Y.Offset.."}" end
local CF=mt("CFrame",{})
CF.__index=function(t,k) if k=="p" then return t.Position elseif k=="X" then return t.Position.X elseif k=="Y" then return t.Position.Y elseif k=="Z" then return t.Position.Z end return CF[k] end
CF.__mul=function(a,b) if typeOf(b)=="Vector3" then return a.Position+b end return CFrame.new(a.Position+b.Position) end
CF.__tostring=function(a) return tostring(a.Position) end
CFrame={new=function(x,y,z) if type(x)=="table" then return setmetatable({Position=x},CF) end return setmetatable({Position=Vector3.new(x or 0,y or 0,z or 0)},CF) end}
CFrame.Angles=function() return CFrame.new(0,0,0) end
CFrame.lookAt=function(a) return CFrame.new(a) end
CFrame.identity=CFrame.new(0,0,0)
local BCN={["Bright red"]={196,40,28},["Bright blue"]={13,105,172},["Bright green"]={75,151,75},["Bright yellow"]={245,205,48},["Really black"]={17,17,17},["Black"]={27,42,53},["White"]={242,243,243},["Medium stone grey"]={163,162,165},["Bright orange"]={218,133,65},["Hot pink"]={255,102,204},["Cyan"]={4,175,236},["Lime green"]={0,255,0},["Really red"]={255,0,0},["Really blue"]={0,0,255},["Deep orange"]={255,111,0},["Royal purple"]={98,37,209},["Brown"]={124,92,70},["Dark stone grey"]={99,95,98}}
local BCm=mt("BrickColor",{}) BCm.__index=BCm
BrickColor={new=function(n) local c=BCN[n] or BCN["Medium stone grey"] return setmetatable({Name=n,Color=Color3.fromRGB(c[1],c[2],c[3])},BCm) end,
 Random=function() local names={} for k in pairs(BCN) do names[#names+1]=k end return BrickColor.new(names[math.random(#names)]) end}
for _,n in ipairs({"Red","Blue","Green","Yellow","White","Black"}) do BrickColor[n]=function() return BrickColor.new(n=="Red" and "Bright red" or n=="Blue" and "Bright blue" or n=="Green" and "Bright green" or n=="Yellow" and "Bright yellow" or n) end end
local NR=mt("NumberRange",{}) NR.__index=NR
NumberRange={new=function(a,b) return setmetatable({Min=a or 0,Max=b or a or 0},NR) end}
local NS=mt("NumberSequence",{}) NS.__index=NS
NumberSequence={new=function(a) if type(a)=="table" then a=a[1] and a[1].Value or 1 end return setmetatable({Value=a or 1},NS) end}
local CS=mt("ColorSequence",{}) CS.__index=CS
ColorSequenceKeypoint={new=function(t,c) return {Time=t,Value=c} end}
NumberSequenceKeypoint={new=function(t,v) return {Time=t,Value=v} end}
ColorSequence={new=function(a,b) if type(a)=="table" and not a.R then a=a[1].Value end return setmetatable({Color=a or Color3.new(1,1,1)},CS) end}
Random={new=function(seed) if seed then math.randomseed(seed) end local r={} r.NextNumber=function(self,a,b) a=a or 0 b=b or 1 return a+math.random()*(b-a) end r.NextInteger=function(self,a,b) return math.random(a,b) end return r end}
local EI=mt("EnumItem",{})
EI.__tostring=function(e) return "Enum."..e.EnumType.."."..e.Name end
local function mkEnum(en,names) local E={} for i,n in ipairs(names) do E[n]=setmetatable({Name=n,Value=i-1,EnumType=en},EI) end return E end
local kc={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Space","LeftShift","RightShift","LeftControl","Return","Escape","Tab","Up","Down","Left","Right","Backspace"}
Enum={Font=mkEnum("Font",{"SourceSans","SourceSansBold","SourceSansLight","Gotham","GothamBold","GothamMedium","GothamBlack","GothamSemibold","Arial","ArialBold","Code","Fantasy","SciFi","Arcade","Cartoon","Highway","Bangers"}),
 EasingStyle=mkEnum("EasingStyle",{"Linear","Sine","Back","Quad","Quart","Quint","Bounce","Elastic","Exponential","Circular","Cubic"}),
 EasingDirection=mkEnum("EasingDirection",{"In","Out","InOut"}),
 KeyCode=mkEnum("KeyCode",kc),UserInputType=mkEnum("UserInputType",{"Keyboard","MouseButton1","MouseButton2","MouseMovement","Touch"}),
 Material=mkEnum("Material",{"Plastic","Wood","Metal","Neon","Grass","Concrete","Brick","Glass","ForceField","Sand","Ice","Marble"}),
 PartType=mkEnum("PartType",{"Block","Ball","Cylinder"}),TextXAlignment=mkEnum("TextXAlignment",{"Left","Center","Right"}),TextYAlignment=mkEnum("TextYAlignment",{"Top","Center","Bottom"}),
 PlaybackState=mkEnum("PlaybackState",{"Begin","Delayed","Playing","Paused","Completed","Cancelled"}),SortOrder=mkEnum("SortOrder",{"LayoutOrder","Name"}),
 FillDirection=mkEnum("FillDirection",{"Horizontal","Vertical"}),HorizontalAlignment=mkEnum("HorizontalAlignment",{"Left","Center","Right"}),VerticalAlignment=mkEnum("VerticalAlignment",{"Top","Center","Bottom"})}
local TI=mt("TweenInfo",{}) TI.__index=TI
TweenInfo={new=function(t,style,dir,rep,rev,delay) return setmetatable({Time=t or 1,EasingStyle=style or Enum.EasingStyle.Quad,EasingDirection=dir or Enum.EasingDirection.Out,RepeatCount=rep or 0,Reverses=rev or false,DelayTime=delay or 0},TI) end}
-- easing
local function bounceOut(a) local n,d=7.5625,2.75 if a<1/d then return n*a*a elseif a<2/d then a=a-1.5/d return n*a*a+.75 elseif a<2.5/d then a=a-2.25/d return n*a*a+.9375 end a=a-2.625/d return n*a*a+.984375 end
local function eIn(s,a)
  if s=="Sine" then return 1-math.cos(a*math.pi/2) elseif s=="Quad" then return a*a elseif s=="Cubic" then return a^3 elseif s=="Quart" then return a^4 elseif s=="Quint" then return a^5
  elseif s=="Exponential" then return a==0 and 0 or 2^(10*(a-1)) elseif s=="Circular" then return 1-math.sqrt(1-a*a)
  elseif s=="Back" then local c=1.70158 return a*a*((c+1)*a-c)
  elseif s=="Elastic" then return -(2^(10*a-10))*math.sin((a*10-10.75)*(2*math.pi/3))
  elseif s=="Bounce" then return 1-bounceOut(1-a) end
  return a
end
local function ease(s,d,a)
  if a<=0 then return 0 elseif a>=1 then return 1 end
  if s=="Linear" then return a end
  if d=="In" then return eIn(s,a) elseif d=="Out" then return 1-eIn(s,1-a) end
  if a<.5 then return eIn(s,a*2)/2 end
  return 1-eIn(s,(1-a)*2)/2
end
local function lerpV(a,b,t)
  local ty=typeOf(a)
  if ty=="number" then return a+(b-a)*t
  elseif ty=="Color3" then return Color3.new(a.R+(b.R-a.R)*t,a.G+(b.G-a.G)*t,a.B+(b.B-a.B)*t)
  elseif ty=="UDim2" then return UDim2.new(a.X.Scale+(b.X.Scale-a.X.Scale)*t,a.X.Offset+(b.X.Offset-a.X.Offset)*t,a.Y.Scale+(b.Y.Scale-a.Y.Scale)*t,a.Y.Offset+(b.Y.Offset-a.Y.Offset)*t)
  elseif ty=="Vector3" then return a+(b-a)*t
  elseif ty=="Vector2" then return Vector2.new(a.X+(b.X-a.X)*t,a.Y+(b.Y-a.Y)*t)
  elseif ty=="UDim" then return UDim.new(a.Scale+(b.Scale-a.Scale)*t,a.Offset+(b.Offset-a.Offset)*t) end
  if t>=1 then return b end return a
end
local TW=mt("Tween",{})
local TWM={}
TW.__index=TWM
function TWM.Play(self)
  self._from={}
  for k in pairs(self._g) do self._from[k]=self.Instance[k] end
  self._t=-self.TweenInfo.DelayTime self.PlaybackState=Enum.PlaybackState.Playing
  for i,x in ipairs(tweens) do if x==self then table.remove(tweens,i) break end end
  tweens[#tweens+1]=self
end
function TWM.Pause(self) self.PlaybackState=Enum.PlaybackState.Paused end
function TWM.Cancel(self) self.PlaybackState=Enum.PlaybackState.Cancelled end
function TWM.Destroy(self) self.PlaybackState=Enum.PlaybackState.Cancelled end
local function stepTweens(dt)
  for i=#tweens,1,-1 do
    local tw=tweens[i]
    if tw.PlaybackState~=Enum.PlaybackState.Playing then table.remove(tweens,i)
    else
      tw._t=tw._t+dt
      local info=tw.TweenInfo
      if tw._t>=0 then
        local a=info.Time>0 and math.min(1,tw._t/info.Time) or 1
        local e=ease(info.EasingStyle.Name,info.EasingDirection.Name,a)
        for k,g in pairs(tw._g) do tw.Instance[k]=lerpV(tw._from[k],g,e) end
        if a>=1 then tw.PlaybackState=Enum.PlaybackState.Completed table.remove(tweens,i) tw.Completed:Fire(tw.PlaybackState) end
      end
    end
  end
end
-- instances
local nid=1000
local Methods,Special,GUIS,PARTS,MODS={}, {}, {}, {}, {}
GUIN={}
local EVENTS={Touched=1,TouchEnded=1,MouseEnter=1,MouseLeave=1,MouseButton1Click=1,MouseButton1Down=1,MouseButton1Up=1,MouseButton2Click=1,Activated=1,Changed=1,ChildAdded=1,ChildRemoved=1,Died=1,CharacterAdded=1,PlayerAdded=1,InputBegan=1,InputEnded=1,Heartbeat=1,RenderStepped=1,Stepped=1,Completed=1,FocusLost=1,Triggered=1,Chatted=1,Equipped=1,Unequipped=1}
local GUIC={ScreenGui=1,Frame=1,TextLabel=1,TextButton=1,ImageLabel=1,ImageButton=1,TextBox=1,ScrollingFrame=1,UICorner=1,UIStroke=1,UIListLayout=1,UIPadding=1,UIGradient=1,UIAspectRatioConstraint=1,UIScale=1}
local FXC={Fire=1,Smoke=1,Sparkles=1,PointLight=1,SpotLight=1,ParticleEmitter=1,Explosion=1}
local IMT={}
local function mkInst(cls) return setmetatable({_c=cls,_p={Name=cls},_k={},_sig={},_att=false,_id=false,_fx=false,_par=false},IMT) end
local function defaults(cls,p)
  local gray=Color3.fromRGB(163,162,165)
  local dark=Color3.fromRGB(27,42,53)
  if cls=="Frame" or cls=="ScrollingFrame" or cls=="TextLabel" or cls=="TextButton" or cls=="TextBox" or cls=="ImageLabel" or cls=="ImageButton" then
    p.Size=UDim2.new(0,100,0,100) p.Position=UDim2.new(0,0,0,0) p.AnchorPoint=Vector2.new(0,0) p.BackgroundColor3=gray p.BackgroundTransparency=0
    p.BorderSizePixel=1 p.BorderColor3=dark p.Visible=true p.ZIndex=1 p.ClipsDescendants=false p.Rotation=0
    if cls=="TextLabel" or cls=="TextButton" or cls=="TextBox" then
      p.Size=UDim2.new(0,200,0,50) p.Text=(cls=="TextLabel" and "Label") or (cls=="TextButton" and "Button") or "" p.TextColor3=dark p.TextSize=14 p.Font=Enum.Font.SourceSans
      p.TextScaled=false p.TextTransparency=0 p.TextWrapped=false p.TextXAlignment=Enum.TextXAlignment.Center p.TextYAlignment=Enum.TextYAlignment.Center
    end
    if cls=="ImageLabel" or cls=="ImageButton" then p.Image="" p.ImageTransparency=0 end
  elseif cls=="ScreenGui" then p.ResetOnSpawn=true p.Enabled=true p.IgnoreGuiInset=false p.DisplayOrder=0
  elseif cls=="UICorner" then p.CornerRadius=UDim.new(0,8)
  elseif cls=="UIStroke" then p.Thickness=1 p.Color=Color3.new(0,0,0) p.Transparency=0
  elseif cls=="Part" then p.Size=Vector3.new(4,1,2) p.Position=Vector3.new(0,0.5,0) p.Color=gray p.Anchored=false p.CanCollide=true p.Transparency=0 p.Material=Enum.Material.Plastic p.Shape=Enum.PartType.Block p.Rotation=Vector3.new(0,0,0)
  elseif cls=="Fire" then p.Heat=9 p.Size=5 p.Color=Color3.fromRGB(236,139,70) p.SecondaryColor=Color3.fromRGB(139,80,55) p.Enabled=true
  elseif cls=="Smoke" then p.Size=1 p.Color=Color3.fromRGB(100,100,100) p.Opacity=0.5 p.RiseVelocity=1 p.Enabled=true
  elseif cls=="Sparkles" then p.SparkleColor=Color3.fromRGB(144,25,25) p.Enabled=true
  elseif cls=="PointLight" or cls=="SpotLight" then p.Brightness=1 p.Range=8 p.Color=Color3.new(1,1,1) p.Enabled=true
  elseif cls=="ParticleEmitter" then p.Rate=20 p.Lifetime=NumberRange.new(1,2) p.Speed=NumberRange.new(5,5) p.Color=ColorSequence.new(Color3.new(1,1,1)) p.Size=NumberSequence.new(1) p.Enabled=true
  elseif cls=="Explosion" then p.BlastRadius=4 p.BlastPressure=500000 p.DestroyJointRadiusPercent=1 end
end
local function removeFrom(list,x) for i,v in ipairs(list) do if v==x then table.remove(list,i) return end end end
local function push(t,k,v)
  local c=t._c local ty=typeOf(v)
  if GUIC[c] then
    local id=t._id
    if ty=="UDim2" then __gset(id,k,v.X.Scale,v.X.Offset,v.Y.Scale,v.Y.Offset)
    elseif ty=="Color3" then __gset(id,k,v.R,v.G,v.B)
    elseif ty=="Vector2" then __gset(id,k,v.X,v.Y)
    elseif ty=="UDim" then __gset(id,k,v.Scale,v.Offset)
    elseif ty=="EnumItem" then __gset(id,k,v.Name)
    elseif ty=="number" or ty=="string" or ty=="boolean" then __gset(id,k,v) end
  elseif c=="Part" then
    local id=t._id
    if ty=="Vector3" then __pset(id,k,v.X,v.Y,v.Z) elseif ty=="Color3" then __pset(id,k,v.R,v.G,v.B)
    elseif ty=="EnumItem" then __pset(id,k,v.Name) elseif ty=="number" or ty=="string" or ty=="boolean" then __pset(id,k,v) end
  elseif FXC[c] and t._fx then
    if ty=="Color3" then __fxset(t._fx,k,v.R,v.G,v.B) elseif ty=="number" or ty=="boolean" then __fxset(t._fx,k,v)
    elseif ty=="NumberRange" then __fxset(t._fx,k,v.Min,v.Max) elseif ty=="ColorSequence" then __fxset(t._fx,k,v.Color.R,v.Color.G,v.Color.B)
    elseif ty=="NumberSequence" then __fxset(t._fx,k,v.Value) end
  end
end
local function hook(t,k)
  local c=t._c
  if GUIC[c] and t._id then __genable(t._id,k) elseif c=="Part" and t._id and k=="Touched" then __penable(t._id) end
end
local attach,detach
attach=function(t)
  t._att=true
  local c=t._c
  if GUIC[c] then
    nid=nid+1 t._id=nid GUIS[nid]=t
    __gnew(t._id,c)
    for k,v in pairs(t._p) do push(t,k,v) end
    local par=t._par
    local pid=0
    if par then if par._c=="PlayerGui" then pid=1 else pid=par._id or 0 end end
    __gparent(t._id,pid)
    for k in pairs(t._sig) do hook(t,k) end
  elseif c=="Part" then
    local p=t._p
    local id=__pnew(p.Name or "Part",p.Anchored and 1 or 0)
    t._id=id PARTS[id]=t
    for k,v in pairs(p) do push(t,k,v) end
    for k in pairs(t._sig) do hook(t,k) end
  elseif FXC[c] then
    local par=t._par
    if c=="Explosion" then
      local pos=t._p.Position
      if not pos and par and par._c=="Part" then pos=par.Position end
      pos=pos or Vector3.zero
      __explode(pos.X,pos.Y,pos.Z,t._p.BlastRadius or 4)
      task.delay(1,function() t:Destroy() end)
    elseif par and par._c=="Part" and par._id then
      t._fx=__fxnew(par._id,c)
      for k,v in pairs(t._p) do push(t,k,v) end
    end
  end
  for _,k in ipairs(t._k) do attach(k) end
end
detach=function(t)
  for _,k in ipairs(t._k) do detach(k) end
  if not t._att then return end
  t._att=false
  local c=t._c
  if GUIC[c] and t._id then __gdestroy(t._id) GUIS[t._id]=nil
  elseif c=="Part" and t._id then __pdestroy(t._id) PARTS[t._id]=nil
  elseif FXC[c] and t._fx then __fxdel(t._fx) t._fx=false end
  t._id=false
end
local function setParent(t,par)
  local old=t._par
  if old then removeFrom(old._k,t) end
  t._par=par or false
  if par then
    par._k[#par._k+1]=t
    local ca=par._sig.ChildAdded if ca then ca:Fire(t) end
  end
  if par and par._att then attach(t) elseif t._att then detach(t) end
end
IMT.__index=function(t,k)
  local v=rawget(t,"_p")[k]
  if v~=nil then return v end
  if k=="ClassName" then local c=rawget(t,"_c") if c=="CharPart" then return "Part" end return c
  elseif k=="Parent" then return rawget(t,"_par") or nil end
  local m=Methods[k]
  if m then return m end
  if EVENTS[k] then
    local s=rawget(t,"_sig")
    local sg=s[k]
    if not sg then sg=newSignal(function() hook(t,k) end) s[k]=sg end
    return sg
  end
  local sp=Special[rawget(t,"_c")]
  if sp and sp.get then local r=sp.get(t,k) if r~=nil then return r end end
  for _,c in ipairs(rawget(t,"_k")) do if c._p.Name==k then return c end end
  return nil
end
IMT.__newindex=function(t,k,v)
  if k=="Parent" then setParent(t,v) return end
  local c=rawget(t,"_c")
  if k=="BrickColor" and type(v)=="table" then rawget(t,"_p").BrickColor=v k="Color" v=v.Color end
  if k=="CFrame" and typeOf(v)=="CFrame" then k="Position" v=v.Position end
  local sp=Special[c]
  if sp and sp.set and sp.set(t,k,v) then return end
  rawget(t,"_p")[k]=v
  if rawget(t,"_att") then push(t,k,v) end
  local ch=rawget(t,"_sig").Changed
  if ch then ch:Fire(k) end
end
IMT.__tostring=function(t) return tostring(t._p.Name) end
IMT.__type="Instance"
Special.Part={get=function(t,k)
  if t._att and t._id then
    if k=="Position" then return Vector3.new(__pget(t._id,"Position"))
    elseif k=="Size" then return Vector3.new(__pget(t._id,"Size"))
    elseif k=="Color" then local r,g,b=__pget(t._id,"Color") return Color3.new(r,g,b) end
  end
  if k=="CFrame" then return CFrame.new(t.Position) end
end}
Special.CharPart={get=function(t,k)
  if k=="Position" then return Vector3.new(__player("Position")) elseif k=="CFrame" then return CFrame.new(Vector3.new(__player("Position")))
  elseif k=="Size" then return Vector3.new(2,2,1) end
end,set=function(t,k,v)
  if k=="Position" then __player("Position",v.X,v.Y,v.Z) return true end
end}
Special.Humanoid={get=function(t,k)
  if k=="Health" then return __player("Health") elseif k=="MaxHealth" then return 100
  elseif k=="WalkSpeed" then return t._p._ws or 16 elseif k=="JumpPower" then return t._p._jp or 50 end
end,set=function(t,k,v)
  if k=="Health" then __player("Health",v) return true
  elseif k=="WalkSpeed" then t._p._ws=v __player("WalkSpeed",v) return true
  elseif k=="JumpPower" then t._p._jp=v __player("JumpPower",v) return true end
end}
Special.Lighting={get=function(t,k) if k=="ClockTime" then return t._p._ct or 14 end end,
 set=function(t,k,v)
  if k=="ClockTime" then t._p._ct=v __light("ClockTime",v) return true
  elseif k=="TimeOfDay" and type(v)=="string" then local h,m=v:match("(%d+):(%d+)") if h then local ct=tonumber(h)+tonumber(m)/60 t._p._ct=ct __light("ClockTime",ct) end return true end
 end}
Methods.FindFirstChild=function(self,n,rec)
  for _,c in ipairs(self._k) do if c._p.Name==n then return c end end
  if rec then for _,c in ipairs(self._k) do local r=Methods.FindFirstChild(c,n,true) if r then return r end end end
  return nil
end
Methods.FindFirstChildOfClass=function(self,cls) for _,c in ipairs(self._k) do if c._c==cls then return c end end return nil end
Methods.FindFirstChildWhichIsA=function(self,cls) for _,c in ipairs(self._k) do if Methods.IsA(c,cls) then return c end end return nil end
Methods.GetChildren=function(self) local r={} for i,c in ipairs(self._k) do r[i]=c end return r end
Methods.GetDescendants=function(self) local r={} local function walk(x) for _,c in ipairs(x._k) do r[#r+1]=c walk(c) end end walk(self) return r end
Methods.WaitForChild=function(self,n,to)
  local t0=TIME
  while true do
    local c=Methods.FindFirstChild(self,n)
    if c then return c end
    if to and TIME-t0>to then return nil end
    wait(0.05)
  end
end
Methods.IsA=function(self,cls)
  local c=self._c
  if c==cls or cls=="Instance" then return true end
  if cls=="BasePart" or cls=="Part" then return c=="Part" or c=="CharPart" end
  if cls=="GuiObject" then return GUIC[c]~=nil and c~="ScreenGui" and c~="UICorner" and c~="UIStroke" end
  if cls=="GuiButton" then return c=="TextButton" or c=="ImageButton" end
  if cls=="LayerCollector" then return c=="ScreenGui" end
  if cls=="Model" then return c=="Model" end
  return false
end
Methods.Destroy=function(self)
  detach(self)
  local p=self._par
  if p then removeFrom(p._k,self) self._par=false end
  for _,c in ipairs(Methods.GetChildren(self)) do Methods.Destroy(c) end
end
Methods.ClearAllChildren=function(self) for _,c in ipairs(Methods.GetChildren(self)) do Methods.Destroy(c) end end
Methods.Clone=function(self)
  local n=mkInst(self._c)
  for k,v in pairs(self._p) do n._p[k]=v end
  for _,c in ipairs(self._k) do local cc=Methods.Clone(c) cc._par=n n._k[#n._k+1]=cc end
  return n
end
Methods.SetAttribute=function(self,k,v) self._p["@"..k]=v end
Methods.GetAttribute=function(self,k) return self._p["@"..k] end
Methods.TakeDamage=function(self,n) self.Health=self.Health-n end
Methods.Play=function(self) end
Methods.Stop=function(self) end
Methods.Raycast=function() return nil end
Methods.IsClient=function() return true end
Methods.IsServer=function() return false end
Methods.IsStudio=function() return true end
Methods.GetPlayers=function() return {Methods.FindFirstChild(Methods.GetService(nil,"Players"),"LocalPlayer") or nil} end
Methods.AddItem=function(self,item,t) task.delay(t or 10,function() if item then item:Destroy() end end) end
Methods.IsKeyDown=function(self,code) return KEYS[code and code.Name] or false end
Methods.GetService=function(self,n) return SVC[n] or (function() local s=mkInst("Service") s._p.Name=n SVC[n]=s return s end)() end
Methods.Create=function(self,inst,info,goal)
  return setmetatable({Instance=inst,TweenInfo=info,_g=goal,Completed=newSignal(),PlaybackState=Enum.PlaybackState.Begin},TW)
end
Methods.LoadAnimation=function(self,anim) return {Play=function() end,Stop=function() end,Looped=false} end
Methods.GetMouse=function() return {X=0,Y=0,Hit=CFrame.new(0,0,0),Target=nil} end
KEYS={}
SVC={}
Instance={new=function(cls,par)
  local o=mkInst(cls)
  defaults(cls,o._p)
  if par then o.Parent=par end
  return o
end}
local function svc(name,cls) local s=mkInst(cls or name) s._p.Name=name SVC[name]=s return s end
game=svc("Game","DataModel")
workspace=svc("Workspace") workspace._att=true
for _,n in ipairs({"Players","Lighting","ReplicatedStorage","ServerScriptService","ServerStorage","StarterGui","StarterPack","StarterPlayer","SoundService","TweenService","RunService","UserInputService","Debris","Teams","Chat"}) do svc(n) end
SVC.Lighting._c="Lighting"
SVC.Workspace=workspace
for _,s in pairs(SVC) do if s~=game then s._par=game game._k[#game._k+1]=s end end
local RunSvc=SVC.RunService
local UIS=SVC.UserInputService
local Players=SVC.Players
local player=mkInst("Player") player._p.Name=__pname() player._p.UserId=1 player._p.Character=nil
Players._p.LocalPlayer=player
player._par=Players Players._k[#Players._k+1]=player
local PGUI=mkInst("PlayerGui") PGUI._p.Name="PlayerGui" PGUI._att=true PGUI._id=1 PGUI._par=player player._k[#player._k+1]=PGUI
local BP=mkInst("Backpack") BP._p.Name="Backpack" BP._par=player player._k[#player._k+1]=BP
local char=mkInst("Model") char._p.Name=player._p.Name
local hum=mkInst("Humanoid") hum._p.Name="Humanoid" hum._par=char char._k[#char._k+1]=hum
local hrp=mkInst("CharPart") hrp._p.Name="HumanoidRootPart" hrp._par=char char._k[#char._k+1]=hrp
local head=mkInst("CharPart") head._p.Name="Head" head._par=char char._k[#char._k+1]=head
player._p.Character=char
local OnH={}
function on(e,f) OnH[e]=OnH[e] or {} OnH[e][#OnH[e]+1]=f end
local function fireOn(e,...) local l=OnH[e] if l then for _,f in ipairs(l) do spawn(f,...) end end end
function after(s,f) task.delay(s,f) end
function __initworld()
  local n=__pcount()
  for i=0,n-1 do
    local name=__pinfo(i)
    local p=mkInst("Part") p._p.Name=name p._att=true p._id=i PARTS[i]=p
    p._par=workspace workspace._k[#workspace._k+1]=p
  end
end
function __regmod(name,src)
  MODS[name]={src=src}
  local m=mkInst("ModuleScript") m._p.Name=name m._par=SVC.ReplicatedStorage SVC.ReplicatedStorage._k[#SVC.ReplicatedStorage._k+1]=m
end
function require(x)
  local n=type(x)=="table" and x._p.Name or tostring(x)
  local m=MODS[n]
  if not m then error("Module not found: "..n) end
  if not m.loaded then
    local env=setmetatable({script=Methods.FindFirstChild(SVC.ReplicatedStorage,n)},{__index=_G})
    local f,err=load(m.src,"="..n,"t",env)
    if not f then error(err) end
    m.v=f() m.loaded=true
  end
  return m.v
end
function __runscript(name,cls,src,pref)
  local inst=mkInst(cls) inst._p.Name=name
  local par=SVC[pref] or GUIN[pref] or (pref=="StarterPlayerScripts" and SVC.StarterPlayer) or SVC.ServerScriptService
  inst._par=par par._k[#par._k+1]=inst
  local env=setmetatable({script=inst},{__index=_G})
  local f,err=load(src,"="..name,"t",env)
  if not f then print("["..name.."] "..tostring(err)) return end
  spawn(f)
end
function __fire(e,a,b,c)
  if e=="update" then
    TIME=TIME+a stepWaiters() stepTweens(a)
    RunSvc.Heartbeat:Fire(a) RunSvc.RenderStepped:Fire(a) RunSvc.Stepped:Fire(TIME,a)
    fireOn("update",a)
  elseif e=="start" then
    fireOn("start") Players.PlayerAdded:Fire(player) player.CharacterAdded:Fire(char)
  elseif e=="touch" then fireOn("touch",a)
  elseif e=="ptouch" then local p=PARTS[a] if p then p.Touched:Fire(hrp) end
  elseif e=="gui" then local g=GUIS[a] if g then local s=g._sig[b] if s then s:Fire() end end
  elseif e=="key" then
    KEYS[a]=(b==1) or nil
    local inp={KeyCode=Enum.KeyCode[a],UserInputType=Enum.UserInputType.Keyboard,Name=a}
    if b==1 then UIS.InputBegan:Fire(inp,false) else UIS.InputEnded:Fire(inp,false) end
  elseif e=="died" then hum.Died:Fire() fireOn("died")
  elseif e=="respawn" then player.CharacterAdded:Fire(char)
  elseif e=="chat" then player.Chatted:Fire(a) fireOn("chat",a)
  end
end
io=nil debug=nil package=nil dofile=nil loadfile=nil
