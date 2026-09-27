import { useEffect, useState } from "react";

type Screen =
  | "home"
  | "running"
  | "results"
  | "inventory"
  | "product"
  | "orders"
  | "order"
  | "reorder"
  | "approved"
  | "tasks"
  | "activity"
  | "runDetail"
  | "settings";

type IconName =
  | "home"
  | "box"
  | "receipt"
  | "pulse"
  | "spark"
  | "chevron"
  | "arrow"
  | "check"
  | "alert"
  | "search"
  | "plus"
  | "minus"
  | "settings"
  | "bell"
  | "scan"
  | "clock"
  | "shield"
  | "building"
  | "face"
  | "cloud"
  | "info"
  | "package";

const iconPaths: Record<IconName, React.ReactNode> = {
  home: <><path d="M3 10.8 12 3l9 7.8"/><path d="M5.5 9.5V21h13V9.5M9.5 21v-7h5v7"/></>,
  box: <><path d="m4 7 8-4 8 4-8 4-8-4Z"/><path d="M4 7v10l8 4 8-4V7M12 11v10"/></>,
  receipt: <><path d="M6 3h12v18l-3-2-3 2-3-2-3 2V3Z"/><path d="M9 8h6M9 12h6M9 16h3"/></>,
  pulse: <><path d="M4 19V9M10 19V5M16 19v-7M22 19H2"/></>,
  spark: <><path d="m12 2 1.7 5.1L19 9l-5.3 1.9L12 16l-1.7-5.1L5 9l5.3-1.9L12 2Z"/><path d="m19 15 .8 2.2L22 18l-2.2.8L19 21l-.8-2.2L16 18l2.2-.8L19 15Z"/></>,
  chevron: <path d="m9 18 6-6-6-6"/>,
  arrow: <><path d="m15 18 6-6-6-6M21 12H3"/></>,
  check: <path d="m5 12 4 4L19 6"/>,
  alert: <><path d="M12 8v5M12 17h.01"/><path d="M10.3 3.8 2.5 18a2 2 0 0 0 1.8 3h15.4a2 2 0 0 0 1.8-3L13.7 3.8a2 2 0 0 0-3.4 0Z"/></>,
  search: <><circle cx="11" cy="11" r="7"/><path d="m20 20-4-4"/></>,
  plus: <><path d="M12 5v14M5 12h14"/></>,
  minus: <path d="M5 12h14"/>,
  settings: <><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.9l.1.1-2.8 2.8-.1-.1a1.7 1.7 0 0 0-1.9-.3 1.7 1.7 0 0 0-1 1.6v.2h-4V21a1.7 1.7 0 0 0-1-1.6 1.7 1.7 0 0 0-1.9.3l-.1.1L4.2 17l.1-.1a1.7 1.7 0 0 0 .3-1.9A1.7 1.7 0 0 0 3 14H2.8v-4H3a1.7 1.7 0 0 0 1.6-1 1.7 1.7 0 0 0-.3-1.9L4.2 7 7 4.2l.1.1A1.7 1.7 0 0 0 9 4.6a1.7 1.7 0 0 0 1-1.6v-.2h4V3a1.7 1.7 0 0 0 1 1.6 1.7 1.7 0 0 0 1.9-.3l.1-.1L19.8 7l-.1.1a1.7 1.7 0 0 0-.3 1.9 1.7 1.7 0 0 0 1.6 1h.2v4H21a1.7 1.7 0 0 0-1.6 1Z"/></>,
  bell: <><path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9M10 21h4"/></>,
  scan: <><path d="M4 7V4h3M17 4h3v3M20 17v3h-3M7 20H4v-3"/><path d="M8 12h8M12 8v8"/></>,
  clock: <><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></>,
  shield: <><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z"/><path d="m9 12 2 2 4-5"/></>,
  building: <><path d="M4 21V5l8-3 8 3v16M8 8h2M14 8h2M8 12h2M14 12h2M9 21v-5h6v5"/></>,
  face: <><path d="M4 8V5a1 1 0 0 1 1-1h3M16 4h3a1 1 0 0 1 1 1v3M20 16v3a1 1 0 0 1-1 1h-3M8 20H5a1 1 0 0 1-1-1v-3"/><path d="M8 10h.01M16 10h.01M9 15c2 1.5 4 1.5 6 0"/></>,
  cloud: <><path d="M17.5 19H6a4 4 0 0 1-.5-8A7 7 0 0 1 19 9a5 5 0 0 1-1.5 10Z"/><path d="m9 14 2 2 4-4"/></>,
  info: <><circle cx="12" cy="12" r="9"/><path d="M12 11v6M12 7h.01"/></>,
  package: <><path d="m4 8 8-4 8 4-8 4-8-4Z"/><path d="M4 8v9l8 4 8-4V8M8 6l8 4"/></>,
};

function Icon({ name, size = 20 }: { name: IconName; size?: number }) {
  return <svg aria-hidden="true" width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">{iconPaths[name]}</svg>;
}

function Press({ children, onClick, className = "", label }: { children: React.ReactNode; onClick?: () => void; className?: string; label?: string }) {
  return <div role="button" aria-label={label} tabIndex={0} onClick={onClick} onKeyDown={(event) => (event.key === "Enter" || event.key === " ") && onClick?.()} className={`press ${className}`}>{children}</div>;
}

function BackHeader({ title, onBack, action }: { title: string; onBack: () => void; action?: React.ReactNode }) {
  return <div className="back-header"><Press onClick={onBack} className="icon-button" label="Go back"><span className="back-arrow">‹</span></Press><div className="nav-title">{title}</div><div className="header-action">{action}</div></div>;
}

function Badge({ children, tone = "neutral" }: { children: React.ReactNode; tone?: "neutral" | "warning" | "success" | "info" | "danger" }) {
  return <span className={`badge ${tone}`}>{children}</span>;
}

function Card({ children, className = "", onClick }: { children: React.ReactNode; className?: string; onClick?: () => void }) {
  return onClick ? <Press onClick={onClick} className={`card ${className}`}>{children}</Press> : <div className={`card ${className}`}>{children}</div>;
}

const products = [
  { name: "Premium Coffee Beans", sku: "COF-001", stock: 4, status: "Low stock", tone: "danger", category: "Beverages" },
  { name: "Paper Cups", sku: "SUP-014", stock: 12, status: "Low stock", tone: "warning", category: "Supplies" },
  { name: "Vanilla Syrup", sku: "ING-022", stock: 28, status: "In stock", tone: "success", category: "Ingredients" },
  { name: "Northstar Tote Bag", sku: "MER-008", stock: 42, status: "In stock", tone: "success", category: "Merchandise" },
];

const orders = [
  { id: "#ORD-1048", customer: "Maya Chen", total: "$184.50", status: "Delayed", tone: "danger", time: "2 days overdue", items: "6 items" },
  { id: "#ORD-1051", customer: "Jordan Lee", total: "$72.00", status: "Processing", tone: "info", time: "Due today", items: "3 items" },
  { id: "#ORD-1052", customer: "Sam Rivera", total: "$128.25", status: "Pending", tone: "warning", time: "Due tomorrow", items: "4 items" },
];

function Home({ go }: { go: (screen: Screen) => void }) {
  return <div className="page home-page">
    <div className="top-row">
      <div><div className="eyebrow">TUESDAY, JUNE 18</div><div className="hero-title">Good morning, Alex</div><div className="business-name">Northstar Goods</div></div>
      <Press className="avatar" onClick={() => go("settings")} label="Open settings">AG<span className="online-dot" /></Press>
    </div>

    <div className="kpi-grid">
      <Card><div className="kpi-icon blue"><Icon name="box" size={18}/></div><div className="kpi-value">24</div><div className="kpi-label">Products</div></Card>
      <Card><div className="kpi-icon indigo"><Icon name="receipt" size={18}/></div><div className="kpi-value">8</div><div className="kpi-label">Open orders</div></Card>
      <Card><div className="kpi-icon coral"><Icon name="alert" size={18}/></div><div className="kpi-value">3</div><div className="kpi-label">Need attention</div></Card>
    </div>

    <div className="agent-brief">
      <div className="brief-glow" />
      <div className="brief-head"><div className="agent-mark"><Icon name="spark" size={17}/></div><div><div className="brief-label">OPERATIONS AGENT</div><div className="brief-time">Last prepared yesterday</div></div></div>
      <div className="brief-title">Start the day with a clear plan.</div>
      <div className="brief-copy">I’ll review inventory and orders, identify what needs attention, and prepare actions for your approval.</div>
      <Press onClick={() => go("running")} className="primary-button light"><span>Prepare Today</span><Icon name="arrow" size={18}/></Press>
      <div className="privacy-line"><Icon name="shield" size={13}/> Analysis happens on this device</div>
    </div>

    <div className="section-row"><div className="section-title">Needs attention</div><div className="section-count">3 items</div></div>
    <Card className="attention-card" onClick={() => go("product")}>
      <div className="alert-icon"><Icon name="alert" size={18}/></div>
      <div className="grow"><div className="row-title">Premium Coffee Beans</div><div className="row-sub">4 units left · Below minimum of 10</div></div>
      <Icon name="chevron" size={17}/>
    </Card>
    <Card className="attention-card" onClick={() => go("order")}>
      <div className="clock-icon"><Icon name="clock" size={18}/></div>
      <div className="grow"><div className="row-title">Order #ORD-1048 delayed</div><div className="row-sub">Shipment update is 2 days overdue</div></div>
      <Icon name="chevron" size={17}/>
    </Card>

    <div className="section-row"><div className="section-title">Today’s tasks</div><Press onClick={() => go("tasks")} className="text-action">View all</Press></div>
    <Card className="task-preview" onClick={() => go("tasks")}><div className="task-check" /><div className="grow"><div className="row-title">Confirm coffee bean reorder</div><div className="row-sub">High priority · Due 10:00 AM</div></div><Badge tone="danger">High</Badge></Card>
  </div>;
}

function AgentRunning({ go }: { go: (screen: Screen) => void }) {
  const [step, setStep] = useState(1);
  useEffect(() => {
    const timer = window.setInterval(() => setStep((value) => Math.min(value + 1, 4)), 950);
    return () => window.clearInterval(timer);
  }, []);
  const steps = [
    ["Reviewing inventory levels", "24 products scanned", "scan"],
    ["Checking open orders", "8 orders reviewed", "receipt"],
    ["Identifying operational issues", "Comparing thresholds & due dates", "alert"],
    ["Preparing recommended actions", "Prioritizing your next steps", "spark"],
  ] as const;
  return <div className="page dark-page">
    <BackHeader title="Daily preparation" onBack={() => go("home")} />
    <div className="run-hero">
      <div className="orb"><div className="orb-core"><Icon name="spark" size={27}/></div></div>
      <div className="run-kicker">OPERATIONS AGENT</div>
      <div className="run-title">{step === 4 ? "Your plan is ready" : "Preparing your day"}</div>
      <div className="run-copy">{step === 4 ? "I found three items that need your attention." : "Reviewing your business data securely on this device."}</div>
    </div>
    <div className="timeline">
      {steps.map(([title, subtitle, icon], index) => {
        const number = index + 1;
        const state = number < step || step === 4 ? "done" : number === step ? "active" : "pending";
        return <div className={`timeline-step ${state}`} key={title}>
          <div className="timeline-rail"><div className="timeline-node">{state === "done" ? <Icon name="check" size={15}/> : <Icon name={icon} size={17}/>}</div>{index < 3 && <div className="timeline-line" />}</div>
          <div className="timeline-content"><div className="timeline-title">{title}</div><div className="timeline-sub">{state === "pending" ? "Waiting" : subtitle}</div></div>
          {state === "active" && <div className="mini-loader" />}
        </div>;
      })}
    </div>
    <div className="run-spacer" />
    {step === 4 ? <Press className="primary-button mint" onClick={() => go("results")}><span>View My Operations Brief</span><Icon name="arrow" size={18}/></Press> : <div className="secure-note"><Icon name="shield" size={15}/><span>No changes are made without your approval</span></div>}
  </div>;
}

function AgentResults({ go }: { go: (screen: Screen) => void }) {
  const [trace, setTrace] = useState(false);
  return <div className="page">
    <BackHeader title="Today’s brief" onBack={() => go("home")} action={<Badge tone="success">Ready</Badge>} />
    <div className="result-hero"><div className="success-ring"><Icon name="check" size={25}/></div><div><div className="result-title">Your operations are ready</div><div className="result-sub">3 findings · Prepared at 8:42 AM</div></div></div>
    <div className="fact-legend"><span className="fact-dot" />Business fact <span className="suggestion-dot" />AI suggestion</div>
    <div className="section-row"><div className="section-title">Priority findings</div><Badge tone="danger">2 high</Badge></div>
    <Card className="finding-card" onClick={() => go("product")}>
      <div className="finding-top"><Badge tone="danger">HIGH PRIORITY</Badge><Icon name="chevron" size={17}/></div>
      <div className="finding-title">Premium Coffee Beans are critically low</div>
      <div className="fact-box"><span>FACT</span><strong>4 units</strong> remain; your minimum is 10.</div>
      <div className="suggestion"><Icon name="spark" size={15}/><div><b>Suggested next step</b><br/>Review a reorder of 20 units to cover the next 14 days.</div></div>
    </Card>
    <Card className="finding-card" onClick={() => go("product")}>
      <div className="finding-top"><Badge tone="warning">MEDIUM</Badge><Icon name="chevron" size={17}/></div>
      <div className="finding-title">Paper Cups are approaching minimum</div>
      <div className="finding-copy">12 units remain. Based on recent usage, stock may run out in 3 days.</div>
    </Card>
    <Card className="finding-card" onClick={() => go("order")}>
      <div className="finding-top"><Badge tone="danger">HIGH PRIORITY</Badge><Icon name="chevron" size={17}/></div>
      <div className="finding-title">Order #ORD-1048 needs follow-up</div>
      <div className="finding-copy">The carrier update is 2 days overdue. I recommend contacting the customer today.</div>
    </Card>
    <Press className="primary-button" onClick={() => go("tasks")}><Icon name="check" size={18}/><span>Create 3 Tasks</span></Press>
    <Press className="secondary-button" onClick={() => go("reorder")}><Icon name="package" size={18}/><span>Review Reorder</span></Press>
    <Press className="trace-toggle" onClick={() => setTrace(!trace)}><div><div className="trace-title">Agent reasoning & tool trace</div><div className="trace-sub">See how these findings were prepared</div></div><span className={trace ? "rotated" : ""}>⌄</span></Press>
    {trace && <Card className="trace-card"><div className="trace-line"><Badge tone="info">PLAN</Badge><span>Check stock against saved thresholds</span></div><div className="trace-line"><Badge tone="neutral">TOOL</Badge><span>Inventory.readAll → 24 records</span></div><div className="trace-line"><Badge tone="success">RESULT</Badge><span>2 products below target</span></div></Card>}
  </div>;
}

function Inventory({ go }: { go: (screen: Screen) => void }) {
  const [filter, setFilter] = useState("All");
  return <div className="page">
    <div className="screen-header"><div><div className="hero-title">Inventory</div><div className="screen-sub">24 products · Updated just now</div></div><Press className="icon-button dark" label="Add product"><Icon name="plus"/></Press></div>
    <div className="search-field"><Icon name="search" size={18}/><span>Search products or SKU</span></div>
    <div className="chips">{["All", "Low stock", "Beverages", "Supplies"].map((item) => <Press key={item} onClick={() => setFilter(item)} className={`chip ${filter === item ? "selected" : ""}`}>{item}</Press>)}</div>
    <div className="inventory-summary"><div><span className="summary-value">24</span><span>Tracked</span></div><div><span className="summary-value warning-text">2</span><span>Low stock</span></div><div><span className="summary-value">0</span><span>Out of stock</span></div></div>
    <div className="section-row"><div className="section-title">{filter === "All" ? "All products" : filter}</div><div className="section-count">{filter === "All" ? "24" : "2"} items</div></div>
    <div className="product-list">
      {products.filter((product) => filter === "All" || filter === "Low stock" ? filter === "All" || product.status === "Low stock" : product.category === filter).map((product, index) =>
        <Press key={product.sku} onClick={() => go("product")} className="product-row">
          <div className={`product-thumb p${index + 1}`}><Icon name="package" size={22}/></div>
          <div className="grow"><div className="row-title">{product.name}</div><div className="row-sub">{product.sku} · {product.category}</div><Badge tone={product.tone as "danger" | "warning" | "success"}>{product.status}</Badge></div>
          <div className="stock-count"><strong>{product.stock}</strong><span>units</span></div>
        </Press>)}
    </div>
  </div>;
}

function ProductDetail({ go }: { go: (screen: Screen) => void }) {
  return <div className="page">
    <BackHeader title="Product details" onBack={() => go("inventory")} action={<Press className="text-action">Edit</Press>} />
    <div className="product-hero"><div className="large-product"><Icon name="package" size={40}/></div><Badge tone="danger">LOW STOCK</Badge><div className="product-title">Premium Coffee Beans</div><div className="screen-sub">COF-001 · Beverages</div></div>
    <div className="stock-panel"><div><div className="metric-label">CURRENT STOCK</div><div className="large-stock">4 <span>units</span></div></div><div className="stock-divider"/><div><div className="metric-label">MINIMUM</div><div className="large-stock muted">10 <span>units</span></div></div></div>
    <Card className="warning-card"><div className="alert-icon"><Icon name="alert" size={18}/></div><div><div className="row-title">Below your stock threshold</div><div className="row-sub">At current usage, you may run out in 2 days.</div></div></Card>
    <div className="section-title chart-heading">Stock history</div>
    <Card className="chart-card">
      <div className="chart-head"><div><div className="metric-label">LAST 30 DAYS</div><div className="chart-value">−18 units</div></div><Badge tone="neutral">30 days</Badge></div>
      <div className="chart"><div className="threshold">Minimum 10</div><svg viewBox="0 0 320 100" preserveAspectRatio="none"><defs><linearGradient id="area" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stopColor="#A5B4FC" stopOpacity=".35"/><stop offset="1" stopColor="#A5B4FC" stopOpacity="0"/></linearGradient></defs><path className="area" d="M0 12 C40 15 55 24 83 26 S120 35 145 38 S188 51 215 50 S260 70 320 83 L320 100 L0 100Z"/><path className="line" d="M0 12 C40 15 55 24 83 26 S120 35 145 38 S188 51 215 50 S260 70 320 83"/></svg></div>
      <div className="chart-axis"><span>May 20</span><span>Jun 3</span><span>Today</span></div>
    </Card>
    <Press className="primary-button" onClick={() => go("reorder")}><Icon name="package" size={18}/><span>Review Reorder Proposal</span></Press>
  </div>;
}

function Orders({ go }: { go: (screen: Screen) => void }) {
  const [filter, setFilter] = useState("All");
  return <div className="page">
    <div className="screen-header"><div><div className="hero-title">Orders</div><div className="screen-sub">8 open · $1,284.75 total</div></div><Press className="icon-button dark"><Icon name="search"/></Press></div>
    <div className="segmented">{["All", "Pending", "Processing", "Delayed"].map((item) => <Press key={item} onClick={() => setFilter(item)} className={filter === item ? "active" : ""}>{item}</Press>)}</div>
    <div className="section-row"><div className="section-title">{filter === "All" ? "Open orders" : filter}</div><div className="section-count">{filter === "All" ? 8 : filter === "Delayed" ? 1 : 3} orders</div></div>
    {orders.filter((order) => filter === "All" || order.status === filter).map((order) =>
      <Card className="order-card" onClick={() => go("order")} key={order.id}>
        <div className="order-top"><div><div className="order-id">{order.id}</div><div className="row-title">{order.customer}</div></div><div className="order-total">{order.total}</div></div>
        <div className="order-divider" />
        <div className="order-bottom"><Badge tone={order.tone as "danger" | "warning" | "info"}>{order.status}</Badge><span>{order.items}</span><span>·</span><span>{order.time}</span><Icon name="chevron" size={16}/></div>
      </Card>)}
  </div>;
}

function OrderDetail({ go }: { go: (screen: Screen) => void }) {
  const [created, setCreated] = useState(false);
  return <div className="page">
    <BackHeader title="#ORD-1048" onBack={() => go("orders")} action={<Badge tone="danger">Delayed</Badge>} />
    {created && <div className="toast"><Icon name="check" size={17}/> Follow-up task added for today</div>}
    <Card className="customer-card"><div className="avatar small">MC</div><div className="grow"><div className="row-title">Maya Chen</div><div className="row-sub">maya@example.com · (415) 555-0142</div></div><Icon name="chevron" size={17}/></Card>
    <div className="section-title">Order summary</div>
    <Card>
      <div className="summary-line"><span>4 × Ceramic Dripper</span><strong>$116.00</strong></div>
      <div className="summary-line"><span>2 × Coffee Filter Pack</span><strong>$48.00</strong></div>
      <div className="summary-line muted-line"><span>Shipping</span><strong>$20.50</strong></div>
      <div className="total-line"><span>Total</span><strong>$184.50</strong></div>
    </Card>
    <div className="section-title">Status timeline</div>
    <Card className="status-card">
      {[["Order placed", "Jun 14 · 9:24 AM", true], ["Processing", "Jun 14 · 2:10 PM", true], ["Shipped", "Jun 15 · FedEx 7482 9012", true], ["Delivery update", "Expected Jun 16 · Overdue", false]].map(([title, sub, done], index) => <div className={`status-step ${done ? "complete" : "late"}`} key={String(title)}><div className="status-rail"><div className="status-dot">{done && <Icon name="check" size={11}/>}</div>{index < 3 && <div className="status-line"/>}</div><div><div className="row-title">{title}</div><div className="row-sub">{sub}</div></div></div>)}
    </Card>
    <Card className="suggestion-card"><div className="agent-mark"><Icon name="spark" size={16}/></div><div><div className="suggestion-label">AGENT SUGGESTION</div><div className="row-title">Follow up with Maya today</div><div className="row-sub">The promised delivery date passed 2 days ago. A proactive update can protect the customer relationship.</div></div></Card>
    <Press className={`primary-button ${created ? "disabled" : ""}`} onClick={() => setCreated(true)}><Icon name="check" size={18}/><span>{created ? "Task Created" : "Create Follow-up Task"}</span></Press>
  </div>;
}

function Reorder({ go }: { go: (screen: Screen) => void }) {
  const [quantity, setQuantity] = useState(20);
  return <div className="page">
    <BackHeader title="Reorder proposal" onBack={() => go("results")} />
    <div className="proposal-hero"><div className="large-product smallish"><Icon name="package" size={34}/></div><div><Badge tone="danger">LOW STOCK</Badge><div className="proposal-title">Premium Coffee Beans</div><div className="screen-sub">COF-001 · Northline Roasters</div></div></div>
    <Card className="stock-equation"><div><span>Current</span><strong>4</strong></div><span className="equation-arrow">→</span><div><span>Minimum</span><strong>10</strong></div><span className="equation-arrow">→</span><div className="highlight"><span>After reorder</span><strong>{quantity + 4}</strong></div></Card>
    <div className="section-title">Suggested quantity</div>
    <div className="quantity-control"><Press onClick={() => setQuantity(Math.max(1, quantity - 1))} className="quantity-button" label="Decrease quantity"><Icon name="minus"/></Press><div className="quantity-value"><strong>{quantity}</strong><span>units</span></div><Press onClick={() => setQuantity(quantity + 1)} className="quantity-button" label="Increase quantity"><Icon name="plus"/></Press></div>
    <Card className="proposal-details">
      <div className="detail-line"><span>Supplier</span><strong>Northline Roasters</strong></div>
      <div className="detail-line"><span>Unit cost</span><strong>$12.50</strong></div>
      <div className="detail-line total"><span>Estimated total</span><strong>${(quantity * 12.5).toFixed(2)}</strong></div>
    </Card>
    <Card className="explain-card"><div className="agent-mark pale"><Icon name="spark" size={16}/></div><div><div className="suggestion-label">WHY THIS QUANTITY?</div><div className="row-sub">Based on an average of 1.4 units used per day, {quantity} units provides about {Math.round(quantity / 1.4)} days of coverage while keeping stock above your minimum.</div></div></Card>
    <div className="approval-notice"><Icon name="shield" size={19}/><div><strong>You’re in control</strong><span>No order is placed until you review and approve it.</span></div></div>
    <Press className="primary-button" onClick={() => go("approved")}><span>Approve Reorder · ${(quantity * 12.5).toFixed(2)}</span></Press>
    <Press className="secondary-button"><span>Edit Proposal Details</span></Press>
  </div>;
}

function Approved({ go }: { go: (screen: Screen) => void }) {
  return <div className="page success-page"><div className="success-burst"><Icon name="check" size={36}/></div><div className="success-title">Reorder approved</div><div className="success-copy">Your purchase order for 20 units has been approved and prepared for Northline Roasters.</div><Card className="confirmation-card"><div className="detail-line"><span>Reference</span><strong>PO-2091</strong></div><div className="detail-line"><span>Estimated total</span><strong>$250.00</strong></div><div className="detail-line"><span>Status</span><Badge tone="success">Approved</Badge></div></Card><div className="approval-notice"><Icon name="info" size={19}/><div><strong>Next step</strong><span>The purchase order is ready to send. No funds have been charged.</span></div></div><Press className="primary-button" onClick={() => go("home")}>Return to Home</Press><Press className="secondary-button" onClick={() => go("activity")}>View Activity</Press></div>;
}

function Tasks({ go }: { go: (screen: Screen) => void }) {
  const [tab, setTab] = useState("Today");
  const [done, setDone] = useState<number[]>([]);
  const taskData = [
    ["Confirm coffee bean reorder", "Premium Coffee Beans", "10:00 AM", "High"],
    ["Contact Maya about delayed order", "#ORD-1048", "12:00 PM", "High"],
    ["Review paper cup stock", "Paper Cups", "3:00 PM", "Medium"],
    ["Update summer display", "Store operations", "5:00 PM", "Low"],
  ];
  return <div className="page">
    <BackHeader title="Tasks" onBack={() => go("home")} action={<Press className="icon-button dark"><Icon name="plus"/></Press>} />
    <div className="segmented wide">{["Today", "Upcoming", "Completed"].map((item) => <Press key={item} onClick={() => setTab(item)} className={tab === item ? "active" : ""}>{item}</Press>)}</div>
    <div className="task-progress"><div><div className="progress-title">{done.length} of 4 complete</div><div className="screen-sub">A focused day is a good day.</div></div><div className="progress-ring">{done.length}/4</div></div>
    <div className="progress-track"><div style={{ width: `${done.length * 25}%` }} /></div>
    <div className="section-row"><div className="section-title">{tab}</div><div className="section-count">{tab === "Completed" ? done.length : 4 - done.length} tasks</div></div>
    {taskData.map((task, index) => {
      const complete = done.includes(index);
      if (tab === "Completed" && !complete) return null;
      if (tab !== "Completed" && complete) return null;
      return <Card className={`task-card ${complete ? "is-done" : ""}`} key={task[0]}>
        <Press className={`complete-control ${complete ? "checked" : ""}`} onClick={() => setDone((current) => complete ? current.filter((item) => item !== index) : [...current, index])} label={`Mark ${task[0]} complete`}>{complete && <Icon name="check" size={15}/>}</Press>
        <div className="grow"><div className="row-title">{task[0]}</div><div className="task-meta"><span>{task[2]}</span><span>·</span><span>{task[1]}</span></div></div>
        <Badge tone={task[3] === "High" ? "danger" : task[3] === "Medium" ? "warning" : "neutral"}>{task[3]}</Badge>
      </Card>;
    })}
    {tab === "Completed" && done.length === 0 && <div className="empty-state"><div className="empty-icon"><Icon name="check" size={24}/></div><div className="row-title">Nothing completed yet</div><div className="row-sub">Finish a task and it’ll appear here.</div></div>}
  </div>;
}

function Activity({ go }: { go: (screen: Screen) => void }) {
  return <div className="page">
    <div className="screen-header"><div><div className="hero-title">Activity</div><div className="screen-sub">Your business operations record</div></div><Press className="icon-button dark"><Icon name="search"/></Press></div>
    <div className="activity-summary"><div><strong>7</strong><span>Agent runs</span></div><div><strong>12</strong><span>Issues found</span></div><div><strong>9</strong><span>Tasks created</span></div></div>
    <div className="section-row"><div className="section-title">Recent activity</div><Press className="text-action">Filter</Press></div>
    <Card className="run-card" onClick={() => go("runDetail")}>
      <div className="run-card-head"><div className="agent-mark dark"><Icon name="spark" size={16}/></div><div className="grow"><div className="row-title">Daily operations prepared</div><div className="row-sub">Today · 8:42 AM · 18 sec</div></div><Icon name="chevron" size={17}/></div>
      <div className="run-stats"><span><b>3</b> findings</span><span><b>3</b> tasks</span><Badge tone="success">1 approved</Badge></div>
    </Card>
    <div className="date-label">YESTERDAY</div>
    <Card className="activity-row"><div className="activity-icon approved"><Icon name="check" size={17}/></div><div className="grow"><div className="row-title">Reorder approved</div><div className="row-sub">Paper Cups · 50 units · $175.00</div></div><div className="activity-time">4:16 PM</div></Card>
    <Card className="activity-row"><div className="activity-icon"><Icon name="check" size={17}/></div><div className="grow"><div className="row-title">3 tasks completed</div><div className="row-sub">Daily operations tasks</div></div><div className="activity-time">3:40 PM</div></Card>
    <Card className="run-card" onClick={() => go("runDetail")}><div className="run-card-head"><div className="agent-mark dark"><Icon name="spark" size={16}/></div><div className="grow"><div className="row-title">Daily operations prepared</div><div className="row-sub">Yesterday · 8:35 AM · 14 sec</div></div><Icon name="chevron" size={17}/></div><div className="run-stats"><span><b>2</b> findings</span><span><b>2</b> tasks</span><Badge tone="neutral">Reviewed</Badge></div></Card>
  </div>;
}

function RunDetail({ go }: { go: (screen: Screen) => void }) {
  return <div className="page">
    <BackHeader title="Execution detail" onBack={() => go("activity")} action={<Badge tone="success">Complete</Badge>} />
    <div className="run-detail-hero"><div className="agent-mark dark large"><Icon name="spark" size={21}/></div><div className="result-title">Daily operations run</div><div className="result-sub">Today at 8:42 AM · Completed in 18 seconds</div></div>
    <div className="run-detail-stats"><div><strong>3</strong><span>Issues</span></div><div><strong>3</strong><span>Tasks</span></div><div><strong>4</strong><span>Tool calls</span></div></div>
    <div className="section-title">Execution trace</div>
    <div className="execution-list">
      {[["PLAN", "Prepared an inventory and order health check", "Prioritized exceptions that could affect today’s sales."], ["TOOL CALL", "Inventory.readAll()", "Returned 24 product records · 0.8 sec"], ["TOOL CALL", "Orders.getOpen()", "Returned 8 open orders · 0.6 sec"], ["RESULT", "Identified 3 operational issues", "2 stock risks and 1 delayed customer order."], ["RECOMMEND", "Proposed 3 reviewable actions", "No changes were made automatically."]].map(([kind, title, copy], index) => <div className="execution-item" key={title}><div className={`execution-index e${index}`}>{index < 4 ? index + 1 : <Icon name="spark" size={14}/>}</div><div className="execution-content"><Badge tone={kind === "RESULT" ? "success" : kind === "TOOL CALL" ? "info" : "neutral"}>{kind}</Badge><div className="row-title">{title}</div><div className="row-sub">{copy}</div></div></div>)}
    </div>
    <Card className="privacy-card"><Icon name="shield" size={20}/><div><div className="row-title">Processed on device</div><div className="row-sub">Business data used in this run stayed on your iPhone.</div></div></Card>
  </div>;
}

function Settings({ go }: { go: (screen: Screen) => void }) {
  const [faceId, setFaceId] = useState(true);
  const groups = [
    { title: "BUSINESS", items: [["building", "Business profile", "Northstar Goods"], ["alert", "Stock thresholds", "2 custom rules"], ["bell", "Notifications", "Daily brief at 8:30 AM"]] },
    { title: "DATA & PRIVACY", items: [["cloud", "Sync status", "Synced just now"], ["shield", "On-device processing", "Private by default"], ["face", "Face ID", faceId ? "Enabled" : "Disabled"]] },
    { title: "ABOUT", items: [["info", "About SmallBizOps", "Version 1.0"], ["shield", "Privacy & security", "Learn more"]] },
  ] as const;
  return <div className="page settings-page">
    <BackHeader title="Settings" onBack={() => go("home")} />
    <div className="profile-card"><div className="avatar profile">AG</div><div><div className="profile-name">Alex Garcia</div><div className="screen-sub">Owner · Northstar Goods</div></div></div>
    {groups.map((group) => <div className="settings-group" key={group.title}><div className="date-label">{group.title}</div><Card className="settings-card">{group.items.map(([icon, title, sub], index) => <Press key={title} className="setting-row" onClick={title === "Face ID" ? () => setFaceId(!faceId) : undefined}><div className="setting-icon"><Icon name={icon as IconName} size={18}/></div><div className="grow"><div className="row-title">{title}</div><div className="row-sub">{sub}</div></div>{title === "Face ID" ? <div className={`toggle ${faceId ? "on" : ""}`}><span/></div> : <Icon name="chevron" size={16}/>}</Press>)}</Card></div>)}
    <div className="settings-footer"><Icon name="shield" size={16}/>Built for privacy. Designed for small business.</div>
  </div>;
}

function BottomNav({ screen, go }: { screen: Screen; go: (screen: Screen) => void }) {
  const items = [["home", "Home", "home"], ["box", "Inventory", "inventory"], ["receipt", "Orders", "orders"], ["pulse", "Activity", "activity"]] as const;
  return <div className="bottom-nav">{items.map(([icon, label, target]) => <Press key={target} onClick={() => go(target)} className={`nav-item ${screen === target ? "active" : ""}`}><Icon name={icon} size={21}/><span>{label}</span>{screen === target && <i/>}</Press>)}</div>;
}

export default function App() {
  const [screen, setScreen] = useState<Screen>("home");
  const go = (target: Screen) => {
    setScreen(target);
    window.scrollTo({ top: 0, behavior: "smooth" });
  };
  const hasNav = ["home", "inventory", "orders", "activity"].includes(screen);
  return <main className="app-shell">
    <div className={`phone ${screen === "running" ? "phone-dark" : ""}`}>
      <div className="status-bar"><span>9:41</span><div className="status-icons"><span className="signal">▮▮▮</span><span>⌁</span><span className="battery"/></div></div>
      {screen === "home" && <Home go={go}/>}
      {screen === "running" && <AgentRunning go={go}/>}
      {screen === "results" && <AgentResults go={go}/>}
      {screen === "inventory" && <Inventory go={go}/>}
      {screen === "product" && <ProductDetail go={go}/>}
      {screen === "orders" && <Orders go={go}/>}
      {screen === "order" && <OrderDetail go={go}/>}
      {screen === "reorder" && <Reorder go={go}/>}
      {screen === "approved" && <Approved go={go}/>}
      {screen === "tasks" && <Tasks go={go}/>}
      {screen === "activity" && <Activity go={go}/>}
      {screen === "runDetail" && <RunDetail go={go}/>}
      {screen === "settings" && <Settings go={go}/>}
      {hasNav && <BottomNav screen={screen} go={go}/>}
      <div className="home-indicator"/>
    </div>
  </main>;
}
