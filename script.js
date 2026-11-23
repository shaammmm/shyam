const MENU = {
  beverages: [
    {id:"chai",name:"Masala Chai",icon:"☕",price:20,drink:true},
    {id:"kappi",name:"Filter Kappi",icon:"🥛",price:25,drink:true},
    {id:"horlicks",name:"Horlicks",icon:"🧋",price:35,drink:true},
    {id:"boost",name:"Boost",icon:"🥤",price:35,drink:true}
  ],
  snacks:[
    {id:"samosa",name:"Samosa",icon:"🔺",price:15},
    {id:"pazham",name:"Pazham Pori",icon:"🍌",price:18},
    {id:"chicken-roll",name:"Chicken Roll",icon:"🌯",price:40},
    {id:"ullivada",name:"Ulli Vada",icon:"🧅",price:12},
    {id:"parippuvada",name:"Parippu Vada",icon:"🟤",price:12}
  ],
  meals:[
    {id:"porotta",name:"Porotta",icon:"🫓",price:25},
    {id:"dosa",name:"Dosa",icon:"🌙",price:35},
    {id:"idli",name:"Idli",icon:"⚪",price:30},
    {id:"poori",name:"Poori",icon:"🟡",price:40},
    {id:"beef-curry",name:"Beef Curry",icon:"🍛",price:90},
    {id:"chicken-curry",name:"Chicken Curry",icon:"🍲",price:80},
    {id:"fish-fry",name:"Fish Fry",icon:"🐟",price:70},
    {id:"egg-curry",name:"Egg Curry",icon:"🥚",price:55}
  ]
};

const names=["Achu","Malavika","Sethu","Anju","Binu","Faisal","Meera","Pradeep"];
const avatars=["👩🏽","👨🏽","👩🏻","👨🏻","👵🏽","👴🏽","🧕🏽","🧔🏽"];
let customers=[],tray=[],coins=0,served=0,timeLeft=90;
let gameRunning=false,timerId,selectedCustomer=null,pendingDrink=null;
let drinkChoices={milk:"milk",sugar:"sugar"};
const $=(s)=>document.querySelector(s);
const customersEl=$("#customers"),trayEl=$("#tray"),menuGrid=$("#menuGrid");

function allMenuItems(){return Object.values(MENU).flat()}
function findItem(id){return allMenuItems().find((item)=>item.id===id)}
function randomFrom(list){return list[Math.floor(Math.random()*list.length)]}

function makeOrder(){
  const beverage=randomFrom(MENU.beverages);
  const milk=Math.random()>0.5?"milk":"no-milk";
  const sugar=Math.random()>0.5?"sugar":"no-sugar";
  const order=[{id:beverage.id,key:`${beverage.id}|${milk}|${sugar}`}];
  if(Math.random()>0.45){
    const extra=randomFrom([...MENU.snacks,...MENU.meals]);
    order.push({id:extra.id,key:extra.id});
  }
  return order;
}

function createCustomer(){
  const index=Math.floor(Math.random()*names.length);
  return {id:crypto.randomUUID(),name:names[index],avatar:avatars[index],order:makeOrder(),patience:100};
}

function orderLabel(orderItem){
  if(orderItem.key.includes("|")){
    const [id,milk,sugar]=orderItem.key.split("|");
    return `${findItem(id).name} · ${milk==="milk"?"with milk":"no milk"} · ${sugar==="sugar"?"sugar":"no sugar"}`;
  }
  return findItem(orderItem.id).name;
}

function renderCustomers(){
  customersEl.innerHTML="";
  customers.forEach((customer)=>{
    const card=document.createElement("button");
    card.type="button";
    card.className=`customer-card ${customer.selected?"selected":""} ${customer.patience<35?"danger":""}`;
    card.innerHTML=`
      <div class="customer-top"><span class="avatar">${customer.avatar}</span><span class="customer-name">${customer.name}<small>Table 5</small></span></div>
      <div class="customer-order">${customer.order.map((item)=>{
        const matched=tray.some((trayItem)=>trayItem.key===item.key);
        return `<div class="order-item"><span>${orderLabel(item)}</span><span class="${matched?"matched":""}">${matched?"✓":""}</span></div>`;
      }).join("")}</div>
      <div class="patience"><span style="width:${customer.patience}%"></span></div>`;
    card.addEventListener("click",()=>selectCustomer(customer.id));
    customersEl.appendChild(card);
  });
  $("#queueCount").textContent=`${customers.length} waiting`;
}

function selectCustomer(id){
  customers.forEach((customer)=>customer.selected=customer.id===id);
  selectedCustomer=customers.find((customer)=>customer.id===id)||null;
  renderCustomers();
  $("#prepHint").textContent=selectedCustomer?`${selectedCustomer.name}'s order selected`:"Select a menu item";
  updateServeButton();
}

function renderMenu(category="beverages"){
  menuGrid.innerHTML="";
  MENU[category].forEach((item)=>{
    const button=document.createElement("button");
    button.type="button";button.className="menu-item";
    button.innerHTML=`<span class="icon">${item.icon}</span><strong>${item.name}</strong><span class="price">₹${item.price}</span>`;
    button.addEventListener("click",()=>item.drink?openDrinkModal(item):addToTray(item));
    menuGrid.appendChild(button);
  });
}

function openDrinkModal(item){
  pendingDrink=item;drinkChoices={milk:"milk",sugar:"sugar"};
  $("#modifierTitle").textContent=item.name;$("#modifierIcon").textContent=item.icon;
  $("#milkChoices").innerHTML=`<button type="button" data-value="milk" class="selected">With milk</button><button type="button" data-value="no-milk">No milk</button>`;
  $("#sugarChoices").innerHTML=`<button type="button" data-value="sugar" class="selected">Sugar</button><button type="button" data-value="no-sugar">No sugar</button>`;
  $("#modifierModal").classList.add("open");$("#modifierModal").setAttribute("aria-hidden","false");
}

function closeModal(){
  $("#modifierModal").classList.remove("open");$("#modifierModal").setAttribute("aria-hidden","true");pendingDrink=null;
}

function addToTray(item,modifier=null){
  const key=modifier?`${item.id}|${modifier.milk}|${modifier.sugar}`:item.id;
  tray.push({...item,key,modifier});
  renderTray();renderCustomers();updateServeButton();
  showToast(`${item.name} added to tray`);
}

function renderTray(){
  if(!tray.length) trayEl.innerHTML='<span class="tray-empty">Your tray is empty</span>';
  else trayEl.innerHTML=tray.map((item,index)=>`<div class="tray-item" title="${item.name}" data-index="${index}">${item.icon}<small>${item.name}</small></div>`).join("");
  $("#trayTotal").innerHTML=`TOTAL <strong>₹${tray.reduce((sum,item)=>sum+item.price,0)}</strong>`;
}

function updateServeButton(){$("#serveButton").disabled=!selectedCustomer||tray.length===0}

function serveOrder(){
  if(!selectedCustomer||tray.length===0)return;
  const needed=selectedCustomer.order.map((item)=>item.key);
  const prepared=tray.map((item)=>item.key);
  const exact=needed.length===prepared.length&&needed.every((key)=>prepared.includes(key));
  if(!exact){showToast("This tray doesn't match the order");return}

  const tip=Math.round(selectedCustomer.patience/20);
  const total=tray.reduce((sum,item)=>sum+item.price,0)+tip;
  coins+=total;served++;
  $("#coins").textContent=coins;$("#served").textContent=served;
  showToast(`Perfect serve! +₹${total}`);
  customers=customers.filter((customer)=>customer.id!==selectedCustomer.id);
  tray=[];selectedCustomer=null;
  renderTray();renderCustomers();updateServeButton();
  setTimeout(()=>{if(customers.length<3&&gameRunning)customers.push(createCustomer());renderCustomers()},500);
}

function showToast(message){
  const toast=$("#toast");toast.textContent=message;toast.classList.add("show");
  clearTimeout(showToast.timeout);showToast.timeout=setTimeout(()=>toast.classList.remove("show"),1800);
}

function startGame(){
  coins=0;served=0;timeLeft=90;tray=[];
  customers=[createCustomer(),createCustomer(),createCustomer()];
  gameRunning=true;selectedCustomer=null;
  $("#coins").textContent="0";$("#served").textContent="0";$("#timeLeft").textContent=timeLeft;
  $("#startScreen").classList.add("hidden");
  renderTray();renderCustomers();updateServeButton();
  clearInterval(timerId);
  timerId=setInterval(()=>{
    timeLeft--;$("#timeLeft").textContent=timeLeft;
    customers.forEach((customer)=>customer.patience=Math.max(0,customer.patience-1.3));
    customers=customers.filter((customer)=>customer.patience>0);
    while(customers.length<3)customers.push(createCustomer());
    renderCustomers();
    if(timeLeft<=0)endGame();
  },1000);
}

function endGame(){
  gameRunning=false;clearInterval(timerId);
  $(".start-badge").textContent="DAY COMPLETE";$(".start-icon").textContent="🏆";
  $(".eyebrow").textContent="TODAY'S TAKINGS";
  $(".start-card h2").innerHTML=`₹${coins}<br />${served} orders served`;
  $(".start-copy").textContent=served>=8?"Super! The customers left happy.":"A good shift. Open again and beat your score!";
  $("#startButton").innerHTML='Open for another shift <span>→</span>';
  $("#startScreen").classList.remove("hidden");
}

$("#menuTabs").addEventListener("click",(event)=>{
  if(!event.target.dataset.category)return;
  document.querySelectorAll(".menu-tabs button").forEach((button)=>button.classList.remove("active"));
  event.target.classList.add("active");renderMenu(event.target.dataset.category);
});

$("#milkChoices").addEventListener("click",(event)=>{
  if(!event.target.dataset.value)return;
  drinkChoices.milk=event.target.dataset.value;
  event.currentTarget.querySelectorAll("button").forEach((button)=>button.classList.remove("selected"));
  event.target.classList.add("selected");
});
$("#sugarChoices").addEventListener("click",(event)=>{
  if(!event.target.dataset.value)return;
  drinkChoices.sugar=event.target.dataset.value;
  event.currentTarget.querySelectorAll("button").forEach((button)=>button.classList.remove("selected"));
  event.target.classList.add("selected");
});

$("#closeModal").addEventListener("click",closeModal);
$("#modifierModal").addEventListener("click",(event)=>{if(event.target===$("#modifierModal"))closeModal()});
$("#addDrink").addEventListener("click",()=>{
  if(pendingDrink)addToTray(pendingDrink,drinkChoices);closeModal();
});
$("#clearTray").addEventListener("click",()=>{tray=[];renderTray();renderCustomers();updateServeButton()});
$("#serveButton").addEventListener("click",serveOrder);
$("#startButton").addEventListener("click",()=>{
  $(".start-badge").textContent="NOW OPEN";$(".start-icon").textContent="☕";
  $(".eyebrow").textContent="WELCOME TO";
  $(".start-card h2").innerHTML="Shashi's 5 Star<br />Thattukada";
  $(".start-copy").textContent="Keep the queue moving. Match every order and earn tips!";
  $("#startButton").innerHTML='Open the thattukada <span>→</span>';
  startGame();
});

renderMenu("beverages");
