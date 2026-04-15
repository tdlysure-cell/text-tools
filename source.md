```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>直升机全面战争 - Helicopter Total War</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            background: #0a0a0f;
            overflow: hidden;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        #gameContainer {
            position: relative;
            width: 100vw;
            height: 100vh;
            max-width: 1920px;
            max-height: 1080px;
            background: linear-gradient(180deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            overflow: hidden;
        }

        #gameCanvas {
            display: block;
            width: 100%;
            height: 100%;
        }

        /* HUD 界面样式 */
        #hud {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: 10;
        }

        .hud-top {
            position: absolute;
            top: 20px;
            left: 20px;
            right: 20px;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }

        .hud-left, .hud-right {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .bar-container {
            width: 200px;
            height: 24px;
            background: rgba(0, 0, 0, 0.6);
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 12px;
            overflow: hidden;
            position: relative;
        }

        .bar-fill {
            height: 100%;
            transition: width 0.2s ease;
            position: relative;
        }

        .bar-fill::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 50%;
            background: linear-gradient(180deg, rgba(255,255,255,0.3) 0%, transparent 100%);
        }

        #healthBar {
            background: linear-gradient(90deg, #ff4444 0%, #ff6b6b 100%);
            width: 100%;
        }

        #energyBar {
            background: linear-gradient(90deg, #4444ff 0%, #6b6bff 100%);
            width: 100%;
        }

        #shieldBar {
            background: linear-gradient(90deg, #44ffff 0%, #6bffff 100%);
            width: 100%;
        }

        .bar-label {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: white;
            font-size: 12px;
            font-weight: bold;
            text-shadow: 1px 1px 2px rgba(0,0,0,0.8);
        }

        .score-display {
            color: #ffd700;
            font-size: 28px;
            font-weight: bold;
            text-shadow: 0 0 10px rgba(255, 215, 0, 0.5);
        }

        .score-label {
            color: rgba(255, 255, 255, 0.7);
            font-size: 14px;
        }

        .lock-status {
            margin-top: 10px;
            padding: 6px 10px;
            border: 1px solid rgba(255, 255, 255, 0.35);
            border-radius: 8px;
            background: rgba(0, 0, 0, 0.25);
            color: #d6e2ef;
            font-size: 13px;
            font-weight: 600;
            text-align: center;
            letter-spacing: 1px;
        }

        .lock-status.locked {
            color: #ffd18c;
            border-color: rgba(255, 209, 140, 0.75);
            box-shadow: 0 0 12px rgba(255, 209, 140, 0.28);
        }

        .weapon-display {
            display: flex;
            gap: 8px;
            margin-top: 10px;
        }

        .weapon-slot {
            width: 50px;
            height: 50px;
            background: rgba(0, 0, 0, 0.6);
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 8px;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 24px;
            position: relative;
        }

        .weapon-slot.active {
            border-color: #ffd700;
            box-shadow: 0 0 15px rgba(255, 215, 0, 0.5);
        }

        .weapon-cooldown {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 0 0 6px 6px;
        }

        .weapon-cooldown-fill {
            height: 100%;
            background: #ffd700;
            transition: width 0.05s linear;
        }

        /* 游戏状态覆盖层 */
        .overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.85);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            z-index: 100;
            pointer-events: auto;
        }

        .overlay.hidden {
            display: none;
        }

        .overlay h1 {
            font-size: 64px;
            color: #ffd700;
            text-shadow: 0 0 30px rgba(255, 215, 0, 0.5);
            margin-bottom: 20px;
            letter-spacing: 4px;
        }

        .overlay h2 {
            font-size: 36px;
            color: #ff4444;
            margin-bottom: 30px;
        }

        .overlay p {
            color: rgba(255, 255, 255, 0.8);
            font-size: 18px;
            margin-bottom: 10px;
        }

        .overlay .controls {
            margin-top: 30px;
            padding: 20px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            text-align: left;
        }

        .overlay .controls h3 {
            color: #ffd700;
            margin-bottom: 15px;
        }

        .overlay .controls p {
            font-size: 14px;
            margin: 5px 0;
        }

        .overlay .key {
            display: inline-block;
            background: rgba(255, 255, 255, 0.2);
            padding: 4px 10px;
            border-radius: 4px;
            margin-right: 8px;
            font-family: monospace;
        }

        .btn {
            margin-top: 30px;
            padding: 15px 50px;
            font-size: 24px;
            font-weight: bold;
            color: white;
            background: linear-gradient(180deg, #ffd700 0%, #ff8c00 100%);
            border: none;
            border-radius: 30px;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            text-shadow: 1px 1px 2px rgba(0,0,0,0.5);
        }

        .btn:hover {
            transform: scale(1.05);
            box-shadow: 0 0 30px rgba(255, 215, 0, 0.6);
        }

        .final-score {
            font-size: 48px;
            color: #ffd700;
            margin: 20px 0;
        }

        /* 波次显示 */
        #waveDisplay {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 48px;
            color: #ffd700;
            text-shadow: 0 0 20px rgba(255, 215, 0, 0.8);
            opacity: 0;
            transition: opacity 0.5s;
            pointer-events: none;
        }

        #waveDisplay.show {
            opacity: 1;
        }

        /* Boss 血条 */
        #bossHealthContainer {
            position: absolute;
            top: 80px;
            left: 50%;
            transform: translateX(-50%);
            width: 60%;
            display: none;
        }

        #bossHealthContainer.show {
            display: block;
        }

        #bossHealthBar {
            width: 100%;
            height: 30px;
            background: rgba(0, 0, 0, 0.8);
            border: 3px solid #ff0000;
            border-radius: 15px;
            overflow: hidden;
        }

        #bossHealthFill {
            height: 100%;
            background: linear-gradient(90deg, #ff0000 0%, #ff4444 50%, #ff6666 100%);
            transition: width 0.3s ease;
        }

        #bossName {
            text-align: center;
            color: #ff4444;
            font-size: 18px;
            font-weight: bold;
            margin-top: 5px;
            text-shadow: 0 0 10px rgba(255, 0, 0, 0.5);
        }

        /* 连击显示 */
        #comboDisplay {
            position: absolute;
            bottom: 100px;
            right: 30px;
            font-size: 36px;
            color: #ff6b6b;
            font-weight: bold;
            text-shadow: 0 0 15px rgba(255, 107, 107, 0.8);
            opacity: 0;
            transition: opacity 0.3s;
        }

        #comboDisplay.show {
            opacity: 1;
        }

        /* 伤害数字 */
        .damage-number {
            position: absolute;
            color: #ff4444;
            font-size: 20px;
            font-weight: bold;
            text-shadow: 1px 1px 2px rgba(0,0,0,0.8);
            pointer-events: none;
            animation: floatUp 1s ease-out forwards;
        }

        @keyframes floatUp {
            0% {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
            100% {
                opacity: 0;
                transform: translateY(-50px) scale(0.5);
            }
        }

        /* 移动端控制 */
        #mobileControls {
            display: none;
            position: absolute;
            bottom: 20px;
            left: 20px;
            right: 20px;
            justify-content: space-between;
            pointer-events: auto;
        }

        @media (max-width: 768px) {
            #mobileControls {
                display: flex;
            }

            .bar-container {
                width: 120px;
                height: 18px;
            }

            .score-display {
                font-size: 20px;
            }

            .weapon-slot {
                width: 40px;
                height: 40px;
                font-size: 20px;
            }

            .overlay h1 {
                font-size: 36px;
            }

            .overlay h2 {
                font-size: 24px;
            }
        }

        .joystick-area {
            width: 120px;
            height: 120px;
            background: rgba(255, 255, 255, 0.1);
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            position: relative;
        }

        .joystick-knob {
            width: 50px;
            height: 50px;
            background: rgba(255, 255, 255, 0.5);
            border-radius: 50%;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
        }

        .fire-button {
            width: 80px;
            height: 80px;
            background: rgba(255, 68, 68, 0.5);
            border: 3px solid rgba(255, 68, 68, 0.8);
            border-radius: 50%;
            display: flex;
            justify-content: center;
            align-items: center;
            color: white;
            font-size: 24px;
        }

        .fire-button:active {
            background: rgba(255, 68, 68, 0.8);
        }
    </style>
</head>
<body>
    <div id="gameContainer">
        <canvas id="gameCanvas"></canvas>
        
        <!-- HUD 界面 -->
        <div id="hud">
            <div class="hud-top">
                <div class="hud-left">
                    <div class="bar-container">
                        <div id="healthBar" class="bar-fill"></div>
                        <span class="bar-label">HP</span>
                    </div>
                    <div class="bar-container">
                        <div id="shieldBar" class="bar-fill"></div>
                        <span class="bar-label">护盾</span>
                    </div>
                    <div class="bar-container">
                        <div id="energyBar" class="bar-fill"></div>
                        <span class="bar-label">能量</span>
                    </div>
                    <div class="weapon-display">
                        <div class="weapon-slot active" data-weapon="0">🔫
                            <div class="weapon-cooldown"><div class="weapon-cooldown-fill" id="cooldown0"></div></div>
                        </div>
                        <div class="weapon-slot" data-weapon="1">🚀
                            <div class="weapon-cooldown"><div class="weapon-cooldown-fill" id="cooldown1"></div></div>
                        </div>
                        <div class="weapon-slot" data-weapon="2">⚡
                            <div class="weapon-cooldown"><div class="weapon-cooldown-fill" id="cooldown2"></div></div>
                        </div>
                        <div class="weapon-slot" data-weapon="3">🛡️
                            <div class="weapon-cooldown"><div class="weapon-cooldown-fill" id="cooldown3"></div></div>
                        </div>
                    </div>
                </div>
                <div class="hud-right">
                    <div class="score-label">得分</div>
                    <div class="score-display" id="scoreDisplay">0</div>
                    <div class="score-label" style="margin-top: 10px;">波次</div>
                    <div class="score-display" id="waveDisplaySmall">1</div>
                    <div id="missileLockStatus" class="lock-status">MISSILE: SCAN</div>
                </div>
            </div>
        </div>

        <!-- Boss 血条 -->
        <div id="bossHealthContainer">
            <div id="bossHealthBar">
                <div id="bossHealthFill"></div>
            </div>
            <div id="bossName">BOSS</div>
        </div>

        <!-- 波次提示 -->
        <div id="waveDisplay">WAVE 1</div>

        <!-- 连击显示 -->
        <div id="comboDisplay">COMBO x0</div>

        <!-- 移动端控制 -->
        <div id="mobileControls">
            <div class="joystick-area" id="joystick">
                <div class="joystick-knob" id="joystickKnob"></div>
            </div>
            <div class="fire-button" id="fireButton">🔥</div>
        </div>

        <!-- 开始界面 -->
        <div id="startScreen" class="overlay">
            <h1>直升机全面战争</h1>
            <p>HELICOPTER TOTAL WAR</p>
            <div class="controls">
                <h3>操作说明</h3>
                <p><span class="key">W</span><span class="key">A</span><span class="key">S</span><span class="key">D</span> 或 方向键 - 移动直升机</p>
                <p><span class="key">空格</span> 或 <span class="key">鼠标左键</span> - 射击</p>
                <p><span class="key">1</span><span class="key">2</span><span class="key">3</span><span class="key">4</span> - 切换武器</p>
                <p><span class="key">P</span> - 暂停游戏</p>
            </div>
            <button class="btn" id="startBtn">开始游戏</button>
        </div>

        <!-- 暂停界面 -->
        <div id="pauseScreen" class="overlay hidden">
            <h1>游戏暂停</h1>
            <p>PAUSED</p>
            <button class="btn" id="resumeBtn">继续游戏</button>
        </div>

        <!-- 游戏结束界面 -->
        <div id="gameOverScreen" class="overlay hidden">
            <h2>游戏结束</h2>
            <p>GAME OVER</p>
            <div class="final-score" id="finalScore">0</div>
            <p>最终得分</p>
            <button class="btn" id="restartBtn">重新开始</button>
        </div>

        <!-- 胜利界面 -->
        <div id="victoryScreen" class="overlay hidden">
            <h1 style="color: #44ff44;">任务完成！</h1>
            <p>MISSION COMPLETE</p>
            <div class="final-score" id="victoryScore">0</div>
            <p>最终得分</p>
            <button class="btn" id="victoryRestartBtn">再次挑战</button>
        </div>
    </div>

    <script>
        // ============================================
        // 核心游戏引擎 - Core Game Engine
        // ============================================

        /**
         * 游戏配置常量
         * Game Configuration Constants
         */
        const CONFIG = {
            // 渲染设置
            TARGET_FPS: 60,
            DELTA_TIME_MAX: 3,  // 标准化帧步长上限（60FPS=1）
            
            // 物理设置
            GRAVITY: 0.15,
            AIR_RESISTANCE: 0.98,
            INERTIA: 0.92,
            
            // 直升机设置
            HELICOPTER_ACCEL: 0.8,
            HELICOPTER_MAX_SPEED: 8,
            HELICOPTER_TILT_MAX: 0.3,
            
            // 武器设置
            WEAPON_COOLDOWNS: [150, 800, 1200, 3000],  // 毫秒
            WEAPON_ENERGY_COSTS: [0, 30, 25, 50],
            
            // 敌人设置
            ENEMY_SPAWN_RATE: 2000,
            WAVE_DURATION: 30000,
            BOSS_WAVE_INTERVAL: 5,
            
            // 粒子系统
            MAX_PARTICLES: 500,
            PARTICLE_LIFETIME: 60,
        };

        /**
         * 向量工具类
         * Vector Utility Class
         */
        class Vector2 {
            constructor(x = 0, y = 0) {
                this.x = x;
                this.y = y;
            }

            add(v) { return new Vector2(this.x + v.x, this.y + v.y); }
            sub(v) { return new Vector2(this.x - v.x, this.y - v.y); }
            mul(s) { return new Vector2(this.x * s, this.y * s); }
            div(s) { return new Vector2(this.x / s, this.y / s); }
            
            length() { return Math.sqrt(this.x * this.x + this.y * this.y); }
            
            normalize() {
                const len = this.length();
                if (len > 0) return this.div(len);
                return new Vector2();
            }
            
            distance(v) { return this.sub(v).length(); }
            
            clone() { return new Vector2(this.x, this.y); }
        }

        /**
         * 对象池 - 用于频繁创建销毁的对象
         * Object Pool for frequently created/destroyed objects
         */
        class ObjectPool {
            constructor(createFn, initialSize = 50) {
                this.createFn = createFn;
                this.pool = [];
                for (let i = 0; i < initialSize; i++) {
                    this.pool.push(createFn());
                }
            }

            get() {
                return this.pool.length > 0 ? this.pool.pop() : this.createFn();
            }

            release(obj) {
                this.pool.push(obj);
            }
        }

        /**
         * 输入管理器
         * Input Manager
         */
        class InputManager {
            constructor() {
                this.keys = {};
                this.mouse = { x: 0, y: 0, down: false };
                this.joystick = { x: 0, y: 0, active: false };
                this.firePressed = false;
                
                this.setupKeyboard();
                this.setupMouse();
                this.setupTouch();
            }

            setupKeyboard() {
                window.addEventListener('keydown', (e) => {
                    this.keys[e.code] = true;
                    
                    // 武器切换
                    if (e.code === 'Digit1') game.helicopter?.switchWeapon(0);
                    if (e.code === 'Digit2') game.helicopter?.switchWeapon(1);
                    if (e.code === 'Digit3') game.helicopter?.switchWeapon(2);
                    if (e.code === 'Digit4') game.helicopter?.switchWeapon(3);
                    
                    // 暂停
                    if (e.code === 'KeyP') game.togglePause();
                });

                window.addEventListener('keyup', (e) => {
                    this.keys[e.code] = false;
                });
            }

            setupMouse() {
                const canvas = document.getElementById('gameCanvas');
                
                canvas.addEventListener('mousemove', (e) => {
                    const rect = canvas.getBoundingClientRect();
                    this.mouse.x = (e.clientX - rect.left) * (canvas.width / rect.width);
                    this.mouse.y = (e.clientY - rect.top) * (canvas.height / rect.height);
                });

                canvas.addEventListener('mousedown', (e) => {
                    if (e.button === 0) this.mouse.down = true;
                });

                canvas.addEventListener('mouseup', (e) => {
                    if (e.button === 0) this.mouse.down = false;
                });

                canvas.addEventListener('contextmenu', (e) => e.preventDefault());
            }

            setupTouch() {
                const joystick = document.getElementById('joystick');
                const joystickKnob = document.getElementById('joystickKnob');
                const fireButton = document.getElementById('fireButton');
                
                let joystickTouchId = null;
                let joystickCenter = { x: 0, y: 0 };

                joystick.addEventListener('touchstart', (e) => {
                    e.preventDefault();
                    const touch = e.changedTouches[0];
                    joystickTouchId = touch.identifier;
                    
                    const rect = joystick.getBoundingClientRect();
                    joystickCenter = {
                        x: rect.left + rect.width / 2,
                        y: rect.top + rect.height / 2
                    };
                    
                    this.updateJoystick(touch.clientX, touch.clientY, joystickCenter, joystickKnob);
                });

                joystick.addEventListener('touchmove', (e) => {
                    e.preventDefault();
                    for (let touch of e.changedTouches) {
                        if (touch.identifier === joystickTouchId) {
                            this.updateJoystick(touch.clientX, touch.clientY, joystickCenter, joystickKnob);
                        }
                    }
                });

                joystick.addEventListener('touchend', (e) => {
                    e.preventDefault();
                    for (let touch of e.changedTouches) {
                        if (touch.identifier === joystickTouchId) {
                            joystickTouchId = null;
                            this.joystick = { x: 0, y: 0, active: false };
                            joystickKnob.style.transform = 'translate(-50%, -50%)';
                        }
                    }
                });

                fireButton.addEventListener('touchstart', (e) => {
                    e.preventDefault();
                    this.firePressed = true;
                });

                fireButton.addEventListener('touchend', (e) => {
                    e.preventDefault();
                    this.firePressed = false;
                });
            }

            updateJoystick(clientX, clientY, center, knob) {
                const dx = clientX - center.x;
                const dy = clientY - center.y;
                const distance = Math.sqrt(dx * dx + dy * dy);
                const maxDistance = 35;
                
                const clampedDistance = Math.min(distance, maxDistance);
                const angle = Math.atan2(dy, dx);
                
                const knobX = Math.cos(angle) * clampedDistance;
                const knobY = Math.sin(angle) * clampedDistance;
                
                knob.style.transform = `translate(calc(-50% + ${knobX}px), calc(-50% + ${knobY}px))`;
                
                this.joystick = {
                    x: knobX / maxDistance,
                    y: knobY / maxDistance,
                    active: true
                };
            }

            isKeyDown(code) {
                return this.keys[code] || false;
            }

            getMovementInput() {
                let x = 0, y = 0;
                
                if (this.joystick.active) {
                    x = this.joystick.x;
                    y = this.joystick.y;
                } else {
                    if (this.isKeyDown('KeyW') || this.isKeyDown('ArrowUp')) y -= 1;
                    if (this.isKeyDown('KeyS') || this.isKeyDown('ArrowDown')) y += 1;
                    if (this.isKeyDown('KeyA') || this.isKeyDown('ArrowLeft')) x -= 1;
                    if (this.isKeyDown('KeyD') || this.isKeyDown('ArrowRight')) x += 1;
                }
                
                return new Vector2(x, y);
            }

            isFiring() {
                return this.mouse.down || this.firePressed || this.isKeyDown('Space');
            }
        }

        /**
         * 粒子系统
         * Particle System
         */
        class Particle {
            constructor() {
                this.reset();
            }

            reset() {
                this.position = new Vector2();
                this.velocity = new Vector2();
                this.acceleration = new Vector2();
                this.life = 0;
                this.maxLife = 0;
                this.size = 0;
                this.color = '';
                this.alpha = 1;
                this.type = 'normal';
                this.active = false;
            }

            init(x, y, vx, vy, life, size, color, type = 'normal') {
                this.position = new Vector2(x, y);
                this.velocity = new Vector2(vx, vy);
                this.life = life;
                this.maxLife = life;
                this.size = size;
                this.color = color;
                this.type = type;
                this.alpha = 1;
                this.active = true;
            }

            update(dt) {
                if (!this.active) return;
                
                this.velocity = this.velocity.add(this.acceleration.mul(dt));
                this.position = this.position.add(this.velocity.mul(dt));
                this.life -= dt;
                this.alpha = Math.max(0, this.life / this.maxLife);
                
                if (this.life <= 0) {
                    this.active = false;
                }
            }

            render(ctx) {
                if (!this.active) return;
                
                ctx.save();
                ctx.globalAlpha = this.alpha;
                ctx.fillStyle = this.color;
                
                if (this.type === 'spark') {
                    ctx.beginPath();
                    ctx.arc(this.position.x, this.position.y, this.size * this.alpha, 0, Math.PI * 2);
                    ctx.fill();
                } else if (this.type === 'smoke') {
                    ctx.beginPath();
                    ctx.arc(this.position.x, this.position.y, this.size * (2 - this.alpha), 0, Math.PI * 2);
                    ctx.fill();
                } else {
                    ctx.fillRect(
                        this.position.x - this.size / 2,
                        this.position.y - this.size / 2,
                        this.size,
                        this.size
                    );
                }
                
                ctx.restore();
            }
        }

        class ParticleSystem {
            constructor() {
                this.particles = [];
                this.pool = new ObjectPool(() => new Particle(), CONFIG.MAX_PARTICLES);
            }

            emit(x, y, count, config = {}) {
                for (let i = 0; i < count; i++) {
                    const particle = this.pool.get();
                    const angle = Math.random() * Math.PI * 2;
                    const speed = config.speed || (Math.random() * 3 + 1);
                    const life = config.life || (Math.random() * 30 + 20);
                    const size = config.size || (Math.random() * 4 + 2);
                    
                    particle.init(
                        x, y,
                        Math.cos(angle) * speed,
                        Math.sin(angle) * speed,
                        life,
                        size,
                        config.color || '#ff6600',
                        config.type || 'normal'
                    );
                    
                    this.particles.push(particle);
                }
            }

            emitExplosion(x, y, size = 1) {
                // 火焰粒子
                this.emit(x, y, 20 * size, {
                    speed: 5,
                    life: 40,
                    size: 6,
                    color: '#ff4400',
                    type: 'spark'
                });
                
                // 烟雾粒子
                this.emit(x, y, 15 * size, {
                    speed: 2,
                    life: 60,
                    size: 10,
                    color: '#666666',
                    type: 'smoke'
                });
                
                // 火花粒子
                this.emit(x, y, 30 * size, {
                    speed: 8,
                    life: 25,
                    size: 3,
                    color: '#ffff00',
                    type: 'spark'
                });
            }

            emitTrail(x, y, color = '#00ffff') {
                const particle = this.pool.get();
                particle.init(
                    x, y,
                    (Math.random() - 0.5) * 0.5,
                    (Math.random() - 0.5) * 0.5,
                    20,
                    3,
                    color,
                    'smoke'
                );
                this.particles.push(particle);
            }

            update(dt) {
                for (let i = this.particles.length - 1; i >= 0; i--) {
                    const particle = this.particles[i];
                    particle.update(dt);
                    
                    if (!particle.active) {
                        this.particles.splice(i, 1);
                        this.pool.release(particle);
                    }
                }
            }

            render(ctx) {
                for (const particle of this.particles) {
                    particle.render(ctx);
                }
            }

            clear() {
                for (const particle of this.particles) {
                    this.pool.release(particle);
                }
                this.particles = [];
            }
        }

        /**
         * 子弹类
         * Bullet Class
         */
        class Bullet {
            constructor() {
                this.reset();
            }

            reset() {
                this.position = new Vector2();
                this.velocity = new Vector2();
                this.damage = 10;
                this.size = 5;
                this.color = '#ff3b00';
                this.type = 'normal';
                this.active = false;
                this.owner = 'player';
                this.lifetime = 120;
                this.age = 0;
                this.missileLocked = false;
                this.missileCruiseSpeed = 4.2;
                this.missileAttackSpeed = 9.8;
            }

            init(x, y, vx, vy, damage, type = 'normal', owner = 'player') {
                this.position = new Vector2(x, y);
                this.velocity = new Vector2(vx, vy);
                this.damage = damage;
                this.type = type;
                this.owner = owner;
                this.active = true;
                this.age = 0;
                
                switch (type) {
                    case 'missile':
                        this.size = 12;
                        this.color = '#d06a2b';
                        this.lifetime = 180;
                        // 发射即尝试锁定，避免表现得像普通平移子弹
                        if (owner === 'player') {
                            const launchTarget = this.findNearestEnemy();
                            if (launchTarget) {
                                const launchDir = launchTarget.position.sub(this.position).normalize();
                                this.velocity = launchDir.mul(this.missileCruiseSpeed);
                                this.missileLocked = true;
                            } else {
                                this.velocity = this.velocity.normalize().mul(this.missileCruiseSpeed);
                                this.missileLocked = false;
                            }
                        }
                        break;
                    case 'plasma':
                        this.size = 12;
                        this.color = '#2d8fb8';
                        this.lifetime = 90;
                        break;
                    case 'shield':
                        this.size = 20;
                        this.color = '#3f8ea3';
                        this.lifetime = 300;
                        break;
                    case 'sam':
                        this.size = 14;
                        this.color = '#7f4fd1';
                        this.lifetime = 420;
                        break;
                    case 'groundmg':
                        this.size = 4;
                        this.color = '#8a4f2f';
                        this.lifetime = 78;
                        break;
                    default:
                        this.size = owner === 'enemy' ? 5 : 5;
                        this.color = owner === 'enemy' ? '#5a2b2b' : '#cf5b2e';
                        this.lifetime = 120;
                }
            }

            update(dt) {
                if (!this.active) return;
                
                this.age += dt;
                
                // 导弹追踪逻辑
                if (this.type === 'missile' && this.owner === 'player') {
                    const target = this.findNearestEnemy();
                    if (target) {
                        // 第二阶段：发现目标后快速突防
                        this.missileLocked = true;
                        const toTarget = target.position.sub(this.position);
                        const distance = toTarget.length();
                        if (distance > 0) {
                            const steering = toTarget.normalize().mul(0.62);
                            this.velocity = this.velocity.add(steering);
                            this.velocity = this.velocity.normalize().mul(this.missileAttackSpeed);
                        }
                    } else {
                        // 第一阶段：巡弋搜索，低速飞行
                        this.missileLocked = false;
                        const cruiseDir = this.velocity.length() > 0 ? this.velocity.normalize() : new Vector2(1, 0);
                        this.velocity = cruiseDir.mul(this.missileCruiseSpeed);
                    }
                }

                // 地面防空导弹追踪：慢速大杀伤、全屏追踪
                if (this.type === 'sam' && this.owner === 'ground') {
                    const target = game.helicopter;
                    if (target) {
                        const toTarget = target.position.sub(this.position);
                        if (toTarget.length() > 0) {
                            const steering = toTarget.normalize().mul(0.42);
                            this.velocity = this.velocity.add(steering);
                            this.velocity = this.velocity.normalize().mul(4.2);
                        }
                    }
                }

                if (this.type === 'groundmg' && this.owner === 'ground') {
                    // 地面机枪弹：短射程
                    const speed = 5.4;
                    if (this.velocity.length() > 0) {
                        this.velocity = this.velocity.normalize().mul(speed);
                    }
                }
                
                this.position = this.position.add(this.velocity.mul(dt));
                
                if (this.age >= this.lifetime) {
                    this.active = false;
                }
            }

            findNearestEnemy() {
                let nearest = null;
                let minDist = Infinity;
                
                for (const enemy of game.enemies) {
                    if (!enemy.active) continue;
                    const dist = this.position.distance(enemy.position);
                    if (dist < minDist && dist < 560) {
                        minDist = dist;
                        nearest = enemy;
                    }
                }
                
                return nearest;
            }

            render(ctx) {
                if (!this.active) return;
                
                ctx.save();
                
                if (this.type === 'missile') {
                    // 空对空导弹渲染（放大 1.5 倍并增加细节）
                    ctx.translate(this.position.x, this.position.y);
                    const angle = Math.atan2(this.velocity.y, this.velocity.x);
                    ctx.rotate(angle);

                    // 弹体
                    const missileGrad = ctx.createLinearGradient(-16, 0, 16, 0);
                    missileGrad.addColorStop(0, '#bcc5cf');
                    missileGrad.addColorStop(0.5, '#d9e0e7');
                    missileGrad.addColorStop(1, '#9eaab5');
                    ctx.fillStyle = missileGrad;
                    ctx.beginPath();
                    ctx.moveTo(24, 0);
                    ctx.lineTo(12, -4.5);
                    ctx.lineTo(-16, -4.5);
                    ctx.lineTo(-22, -2);
                    ctx.lineTo(-22, 2);
                    ctx.lineTo(-16, 4.5);
                    ctx.lineTo(12, 4.5);
                    ctx.closePath();
                    ctx.fill();

                    // 雷达导引头
                    ctx.fillStyle = '#687683';
                    ctx.beginPath();
                    ctx.arc(19.5, 0, 2.8, 0, Math.PI * 2);
                    ctx.fill();

                    // 弹体分割线
                    ctx.strokeStyle = 'rgba(70, 82, 92, 0.55)';
                    ctx.lineWidth = 0.9;
                    ctx.beginPath();
                    ctx.moveTo(6, -4.2);
                    ctx.lineTo(6, 4.2);
                    ctx.moveTo(-8, -4.2);
                    ctx.lineTo(-8, 4.2);
                    ctx.stroke();

                    // 主翼
                    ctx.fillStyle = '#8a98a5';
                    ctx.beginPath();
                    ctx.moveTo(-4, -4.5);
                    ctx.lineTo(-13.5, -9);
                    ctx.lineTo(-9.5, -3.5);
                    ctx.closePath();
                    ctx.fill();
                    ctx.beginPath();
                    ctx.moveTo(-4, 4.5);
                    ctx.lineTo(-13.5, 9);
                    ctx.lineTo(-9.5, 3.5);
                    ctx.closePath();
                    ctx.fill();

                    // 尾翼
                    ctx.fillStyle = '#7d8a96';
                    ctx.beginPath();
                    ctx.moveTo(-17, -3.8);
                    ctx.lineTo(-23.5, -8.5);
                    ctx.lineTo(-18.5, -2);
                    ctx.closePath();
                    ctx.fill();
                    ctx.beginPath();
                    ctx.moveTo(-17, 3.8);
                    ctx.lineTo(-23.5, 8.5);
                    ctx.lineTo(-18.5, 2);
                    ctx.closePath();
                    ctx.fill();

                    // 尾喷焰（降低炫目，增加层次）
                    ctx.fillStyle = '#f09a4a';
                    ctx.beginPath();
                    ctx.moveTo(-22, -2.8);
                    ctx.lineTo(-33 - Math.random() * 7, 0);
                    ctx.lineTo(-22, 2.8);
                    ctx.closePath();
                    ctx.fill();
                    ctx.fillStyle = 'rgba(255, 220, 160, 0.72)';
                    ctx.beginPath();
                    ctx.moveTo(-22, -1.5);
                    ctx.lineTo(-27 - Math.random() * 4, 0);
                    ctx.lineTo(-22, 1.5);
                    ctx.closePath();
                    ctx.fill();
                    
                } else if (this.type === 'plasma') {
                    // 等离子弹渲染
                    const gradient = ctx.createRadialGradient(
                        this.position.x, this.position.y, 0,
                        this.position.x, this.position.y, this.size
                    );
                    gradient.addColorStop(0, 'rgba(122, 190, 220, 0.95)');
                    gradient.addColorStop(0.55, 'rgba(72, 140, 178, 0.45)');
                    gradient.addColorStop(1, 'rgba(44, 88, 118, 0)');
                    
                    ctx.fillStyle = gradient;
                    ctx.beginPath();
                    ctx.arc(this.position.x, this.position.y, this.size, 0, Math.PI * 2);
                    ctx.fill();
                    
                } else if (this.type === 'shield') {
                    // 护盾渲染
                    ctx.strokeStyle = '#4d9ab0';
                    ctx.lineWidth = 3;
                    ctx.beginPath();
                    ctx.arc(this.position.x, this.position.y, this.size, 0, Math.PI * 2);
                    ctx.stroke();
                    
                    ctx.fillStyle = 'rgba(77, 154, 176, 0.18)';
                    ctx.fill();
                } else if (this.type === 'sam') {
                    // 地面防空导弹：长度大于直升机导弹，颜色独立
                    ctx.translate(this.position.x, this.position.y);
                    const angle = Math.atan2(this.velocity.y, this.velocity.x);
                    ctx.rotate(angle);

                    const bodyGrad = ctx.createLinearGradient(-24, 0, 26, 0);
                    bodyGrad.addColorStop(0, '#7f4fd1');
                    bodyGrad.addColorStop(0.55, '#9e76e2');
                    bodyGrad.addColorStop(1, '#5f3ca2');
                    ctx.fillStyle = bodyGrad;
                    ctx.beginPath();
                    ctx.moveTo(28, 0);
                    ctx.lineTo(14, -5);
                    ctx.lineTo(-18, -5);
                    ctx.lineTo(-24, -2.5);
                    ctx.lineTo(-24, 2.5);
                    ctx.lineTo(-18, 5);
                    ctx.lineTo(14, 5);
                    ctx.closePath();
                    ctx.fill();

                    ctx.fillStyle = '#d8c8ff';
                    ctx.beginPath();
                    ctx.arc(22, 0, 3.2, 0, Math.PI * 2);
                    ctx.fill();

                    ctx.fillStyle = '#6d4ab4';
                    ctx.beginPath();
                    ctx.moveTo(-9, -5);
                    ctx.lineTo(-18, -10);
                    ctx.lineTo(-14, -4);
                    ctx.closePath();
                    ctx.fill();
                    ctx.beginPath();
                    ctx.moveTo(-9, 5);
                    ctx.lineTo(-18, 10);
                    ctx.lineTo(-14, 4);
                    ctx.closePath();
                    ctx.fill();

                    ctx.fillStyle = '#ff9d5a';
                    ctx.beginPath();
                    ctx.moveTo(-24, -2.8);
                    ctx.lineTo(-36 - Math.random() * 7, 0);
                    ctx.lineTo(-24, 2.8);
                    ctx.closePath();
                    ctx.fill();
                    ctx.fillStyle = 'rgba(255, 227, 172, 0.7)';
                    ctx.beginPath();
                    ctx.moveTo(-24, -1.4);
                    ctx.lineTo(-30 - Math.random() * 4, 0);
                    ctx.lineTo(-24, 1.4);
                    ctx.closePath();
                    ctx.fill();
                } else if (this.type === 'groundmg') {
                    ctx.fillStyle = this.color;
                    ctx.beginPath();
                    ctx.arc(this.position.x, this.position.y, this.size, 0, Math.PI * 2);
                    ctx.fill();
                    ctx.strokeStyle = '#f3d9b7';
                    ctx.lineWidth = 1;
                    ctx.stroke();
                    
                } else {
                    // 普通子弹渲染
                    ctx.fillStyle = this.color;
                    ctx.shadowColor = this.color;
                    ctx.shadowBlur = this.owner === 'enemy' ? 2 : 4;
                    ctx.beginPath();
                    ctx.arc(this.position.x, this.position.y, this.size, 0, Math.PI * 2);
                    ctx.fill();
                    // 高对比描边，白天背景下更清晰
                    ctx.strokeStyle = this.owner === 'enemy' ? '#f1d9d9' : '#ffe6cf';
                    ctx.lineWidth = 1.2;
                    ctx.stroke();
                }
                
                ctx.restore();
            }
        }

        /**
         * 子弹管理器
         * Bullet Manager
         */
        class BulletManager {
            constructor() {
                this.bullets = [];
                this.pool = new ObjectPool(() => new Bullet(), 200);
            }

            spawn(x, y, vx, vy, damage, type = 'normal', owner = 'player') {
                const bullet = this.pool.get();
                bullet.init(x, y, vx, vy, damage, type, owner);
                this.bullets.push(bullet);
                return bullet;
            }

            update(dt) {
                for (let i = this.bullets.length - 1; i >= 0; i--) {
                    const bullet = this.bullets[i];
                    bullet.update(dt);
                    
                    // 边界检查
                    if (bullet.position.x < -50 || bullet.position.x > game.canvas.width + 50 ||
                        bullet.position.y < -50 || bullet.position.y > game.canvas.height + 50 ||
                        !bullet.active) {
                        this.bullets.splice(i, 1);
                        this.pool.release(bullet);
                    }
                }
            }

            render(ctx) {
                for (const bullet of this.bullets) {
                    bullet.render(ctx);
                }
            }

            clear() {
                for (const bullet of this.bullets) {
                    this.pool.release(bullet);
                }
                this.bullets = [];
            }
        }

        /**
         * 直升机类
         * Helicopter Class
         */
        class Helicopter {
            constructor(x, y) {
                this.position = new Vector2(x, y);
                this.velocity = new Vector2();
                this.acceleration = new Vector2();
                
                this.width = 90;
                this.height = 60;
                
                this.health = 100;
                this.maxHealth = 100;
                this.shield = 50;
                this.maxShield = 50;
                this.energy = 100;
                this.maxEnergy = 100;
                
                this.currentWeapon = 0;
                this.weaponCooldowns = [0, 0, 0, 0];
                this.lastFireTime = 0;
                
                this.tilt = 0;
                this.propellerAngle = 0;
                
                this.invincible = false;
                this.invincibleTime = 0;
                
                this.shieldActive = false;
                this.shieldRadius = 80;
                this.shieldTime = 0;
            }

            update(dt) {
                // 获取输入
                const input = game.input.getMovementInput();
                
                // 应用加速度
                this.acceleration = input.mul(CONFIG.HELICOPTER_ACCEL);
                
                // 应用物理
                this.velocity = this.velocity.add(this.acceleration);
                this.velocity = this.velocity.mul(CONFIG.INERTIA);
                
                // 限制最大速度
                const speed = this.velocity.length();
                if (speed > CONFIG.HELICOPTER_MAX_SPEED) {
                    this.velocity = this.velocity.normalize().mul(CONFIG.HELICOPTER_MAX_SPEED);
                }
                
                // 更新位置
                this.position = this.position.add(this.velocity.mul(dt));
                
                // 计算倾斜角度
                this.tilt = this.velocity.x / CONFIG.HELICOPTER_MAX_SPEED * CONFIG.HELICOPTER_TILT_MAX;
                this.tilt = Math.max(-CONFIG.HELICOPTER_TILT_MAX, Math.min(CONFIG.HELICOPTER_TILT_MAX, this.tilt));
                
                // 螺旋桨旋转
                this.propellerAngle += 0.5;
                
                // 边界限制
                this.position.x = Math.max(this.width / 2, Math.min(game.canvas.width - this.width / 2, this.position.x));
                this.position.y = Math.max(this.height / 2, Math.min(game.canvas.height - this.height / 2, this.position.y));
                
                // 武器冷却
                for (let i = 0; i < this.weaponCooldowns.length; i++) {
                    if (this.weaponCooldowns[i] > 0) {
                        this.weaponCooldowns[i] -= dt * 16.67;  // 转换为毫秒
                    }
                }
                
                // 射击
                if (game.input.isFiring()) {
                    this.fire();
                }
                
                // 护盾更新
                if (this.shieldActive) {
                    this.shieldTime -= dt;
                    if (this.shieldTime <= 0) {
                        this.shieldActive = false;
                    }
                }
                
                // 无敌时间
                if (this.invincible) {
                    this.invincibleTime -= dt;
                    if (this.invincibleTime <= 0) {
                        this.invincible = false;
                    }
                }
                
                // 能量恢复
                this.energy = Math.min(this.maxEnergy, this.energy + 0.05);
                
                // 护盾恢复
                if (!this.shieldActive) {
                    this.shield = Math.min(this.maxShield, this.shield + 0.02);
                }
                
                // 尾迹粒子
                if (Math.random() < 0.3) {
                    game.particles.emitTrail(
                        this.position.x - 32,
                        this.position.y + 14,
                        '#00aaff'
                    );
                }
            }

            fire() {
                const now = Date.now();
                const cooldown = CONFIG.WEAPON_COOLDOWNS[this.currentWeapon];
                const energyCost = CONFIG.WEAPON_ENERGY_COSTS[this.currentWeapon];
                
                if (now - this.lastFireTime < cooldown) return;
                if (this.energy < energyCost) return;
                
                this.energy -= energyCost;
                this.lastFireTime = now;
                this.weaponCooldowns[this.currentWeapon] = cooldown;
                
                const bulletSpeed = 12;
                
                switch (this.currentWeapon) {
                    case 0:  // 机枪
                        // 平射弹道（空中目标）
                        game.bullets.spawn(
                            this.position.x + 45,
                            this.position.y - 2,
                            bulletSpeed, 0,
                            10, 'normal', 'player'
                        );
                        // 下压扫射弹道（地面目标）
                        game.bullets.spawn(
                            this.position.x + 38,
                            this.position.y + 10,
                            bulletSpeed * 0.9, bulletSpeed * 0.52,
                            9, 'normal', 'player'
                        );
                        game.audio.playSound('shoot');
                        break;
                        
                    case 1:  // 导弹
                        game.bullets.spawn(
                            this.position.x + 45,
                            this.position.y,
                            bulletSpeed * 0.8, 0,
                            30, 'missile', 'player'
                        );
                        game.audio.playSound('missile');
                        break;
                        
                    case 2:  // 电磁炮
                        game.bullets.spawn(
                            this.position.x + 45,
                            this.position.y,
                            bulletSpeed * 1.2, 0,
                            50, 'plasma', 'player'
                        );
                        game.audio.playSound('plasma');
                        break;
                        
                    case 3:  // 防御力场
                        this.activateShield();
                        game.audio.playSound('shield');
                        break;
                }
            }

            activateShield() {
                this.shieldActive = true;
                this.shieldTime = 180;  // 3秒
            }

            switchWeapon(index) {
                if (index >= 0 && index < 4) {
                    this.currentWeapon = index;
                    this.updateWeaponUI();
                }
            }

            updateWeaponUI() {
                const slots = document.querySelectorAll('.weapon-slot');
                slots.forEach((slot, i) => {
                    slot.classList.toggle('active', i === this.currentWeapon);
                });
            }

            takeDamage(damage) {
                if (this.invincible) return;
                
                if (this.shieldActive) {
                    // 护盾吸收伤害
                    this.shield -= damage;
                    if (this.shield <= 0) {
                        this.shieldActive = false;
                        this.shield = 0;
                    }
                    game.particles.emit(this.position.x, this.position.y, 10, {
                        color: '#44ffff',
                        type: 'spark'
                    });
                } else if (this.shield > 0) {
                    // 护盾值吸收
                    this.shield -= damage;
                    if (this.shield < 0) {
                        this.health += this.shield;
                        this.shield = 0;
                    }
                } else {
                    this.health -= damage;
                }
                
                // 受击反馈
                game.screenShake = 5;
                this.invincible = true;
                this.invincibleTime = 30;
                
                game.audio.playSound('hit');
                
                if (this.health <= 0) {
                    game.gameOver();
                }
            }

            render(ctx) {
                ctx.save();
                ctx.translate(this.position.x, this.position.y);
                ctx.rotate(this.tilt);
                
                // 无敌闪烁效果
                if (this.invincible && Math.floor(Date.now() / 100) % 2 === 0) {
                    ctx.globalAlpha = 0.5;
                }
                
                // 主旋翼
                ctx.save();
                ctx.translate(0, -24);
                ctx.rotate(this.propellerAngle);
                ctx.fillStyle = '#1f2328';
                ctx.fillRect(-56, -3, 112, 6);
                ctx.fillRect(-5, -40, 10, 80);
                ctx.restore();
                
                // 主旋翼桅杆
                ctx.fillStyle = '#252a30';
                ctx.fillRect(-5, -24, 10, 12);

                // 机身主壳体（阿帕奇风格：长机鼻+扁平机身）
                const bodyGradient = ctx.createLinearGradient(-45, 0, 45, 0);
                bodyGradient.addColorStop(0, '#2f4f3d');
                bodyGradient.addColorStop(0.5, '#4e6f57');
                bodyGradient.addColorStop(1, '#2b4133');
                ctx.fillStyle = bodyGradient;
                ctx.beginPath();
                ctx.moveTo(46, 0);
                ctx.lineTo(28, -12);
                ctx.lineTo(-15, -16);
                ctx.lineTo(-30, -12);
                ctx.lineTo(-42, -5);
                ctx.lineTo(-42, 5);
                ctx.lineTo(-30, 12);
                ctx.lineTo(-15, 16);
                ctx.lineTo(28, 12);
                ctx.closePath();
                ctx.fill();

                // 机鼻传感器仓
                ctx.fillStyle = '#22272d';
                ctx.beginPath();
                ctx.ellipse(40, 0, 10, 8, 0, 0, Math.PI * 2);
                ctx.fill();
                
                // 串列座舱（前后双舱）
                const canopyGradient = ctx.createLinearGradient(4, -16, 26, 8);
                canopyGradient.addColorStop(0, '#b8e2ff');
                canopyGradient.addColorStop(1, '#5f8eb0');
                ctx.fillStyle = canopyGradient;
                ctx.beginPath();
                ctx.ellipse(10, -7, 15, 7, -0.1, 0, Math.PI * 2);
                ctx.ellipse(23, -2, 13, 7, -0.1, 0, Math.PI * 2);
                ctx.fill();

                // 座舱框架
                ctx.strokeStyle = '#263238';
                ctx.lineWidth = 2;
                ctx.beginPath();
                ctx.moveTo(2, -12);
                ctx.lineTo(30, -4);
                ctx.moveTo(10, -14);
                ctx.lineTo(13, -1);
                ctx.moveTo(22, -10);
                ctx.lineTo(24, 3);
                ctx.stroke();

                // 机身装甲分割线
                ctx.strokeStyle = 'rgba(20, 30, 24, 0.7)';
                ctx.lineWidth = 1.5;
                ctx.beginPath();
                ctx.moveTo(-18, -13);
                ctx.lineTo(26, -9);
                ctx.moveTo(-18, 13);
                ctx.lineTo(26, 9);
                ctx.moveTo(-8, -15);
                ctx.lineTo(-8, 15);
                ctx.stroke();
                
                // 短翼（挂载点）
                ctx.fillStyle = '#3b5a47';
                ctx.beginPath();
                ctx.moveTo(0, -6);
                ctx.lineTo(-12, -17);
                ctx.lineTo(-28, -14);
                ctx.lineTo(-6, -3);
                ctx.closePath();
                ctx.fill();
                ctx.beginPath();
                ctx.moveTo(0, 6);
                ctx.lineTo(-12, 17);
                ctx.lineTo(-28, 14);
                ctx.lineTo(-6, 3);
                ctx.closePath();
                ctx.fill();
                
                // 短翼挂载导弹舱
                ctx.fillStyle = '#20252a';
                for (let i = 0; i < 3; i++) {
                    ctx.fillRect(-30 - i * 6, -16, 4, 3);
                    ctx.fillRect(-30 - i * 6, 13, 4, 3);
                }

                // 尾梁
                const tailGradient = ctx.createLinearGradient(-42, 0, -88, 0);
                tailGradient.addColorStop(0, '#3f604b');
                tailGradient.addColorStop(1, '#2a3f32');
                ctx.fillStyle = tailGradient;
                ctx.beginPath();
                ctx.moveTo(-42, -4);
                ctx.lineTo(-88, -3);
                ctx.lineTo(-88, 3);
                ctx.lineTo(-42, 4);
                ctx.closePath();
                ctx.fill();

                // 垂直尾翼
                ctx.fillStyle = '#334f3f';
                ctx.beginPath();
                ctx.moveTo(-84, -3);
                ctx.lineTo(-91, -18);
                ctx.lineTo(-80, -3);
                ctx.closePath();
                ctx.fill();

                // 水平尾翼
                ctx.fillStyle = '#2f4939';
                ctx.fillRect(-94, -2, 12, 4);

                // 尾桨
                ctx.save();
                ctx.translate(-92, 0);
                ctx.rotate(this.propellerAngle * 1.4);
                ctx.fillStyle = '#23272d';
                ctx.fillRect(-1.5, -11, 3, 22);
                ctx.fillRect(-11, -1.5, 22, 3);
                ctx.restore();
                
                // 主武器炮塔（机腹）
                ctx.fillStyle = '#1b1f24';
                ctx.beginPath();
                ctx.arc(20, 10, 5, 0, Math.PI * 2);
                ctx.fill();
                ctx.fillRect(22, 9, 12, 2);
                ctx.fillRect(22, 11.5, 10, 1.5);

                // 起落架（双橇）
                ctx.strokeStyle = '#2a2f35';
                ctx.lineWidth = 2.5;
                ctx.beginPath();
                ctx.moveTo(-20, 14);
                ctx.lineTo(-26, 24);
                ctx.moveTo(10, 14);
                ctx.lineTo(4, 24);
                ctx.moveTo(-38, 24);
                ctx.lineTo(16, 24);
                ctx.moveTo(-34, 27);
                ctx.lineTo(12, 27);
                ctx.stroke();
                
                ctx.restore();
                
                // 护盾渲染
                if (this.shieldActive) {
                    ctx.save();
                    ctx.strokeStyle = 'rgba(68, 255, 255, 0.5)';
                    ctx.lineWidth = 3;
                    ctx.beginPath();
                    ctx.arc(this.position.x, this.position.y, this.shieldRadius, 0, Math.PI * 2);
                    ctx.stroke();
                    
                    ctx.fillStyle = 'rgba(68, 255, 255, 0.1)';
                    ctx.fill();
                    ctx.restore();
                }
            }

            getBounds() {
                return {
                    x: this.position.x - this.width / 2,
                    y: this.position.y - this.height / 2,
                    width: this.width,
                    height: this.height
                };
            }
        }

        /**
         * 敌人类
         * Enemy Class
         */
        class Enemy {
            constructor(type = 'drone') {
                this.type = type;
                this.position = new Vector2();
                this.velocity = new Vector2();
                this.health = 10;
                this.maxHealth = 10;
                this.damage = 10;
                this.score = 100;
                this.active = false;
                this.age = 0;
                this.behavior = 'straight';
                this.fireRate = 60;
                this.fireCooldown = 0;
                this.size = 30;
                this.rotation = Math.PI;
                this.phaseOffset = Math.random() * Math.PI * 2;
                this.volleyIndex = 0;
                this.subTypeSeed = Math.random();
                
                this.setupType();
            }

            setupType() {
                switch (this.type) {
                    case 'drone':
                        this.health = 10;
                        this.maxHealth = 10;
                        this.damage = 28;
                        this.score = 100;
                        this.size = 45; // 约为玩家直升机 50%
                        this.behavior = 'straight';
                        this.fireRate = 100;
                        break;
                        
                    case 'fighter':
                        this.health = 55;
                        this.maxHealth = 55;
                        this.damage = 18;
                        this.score = 200;
                        this.size = 72;
                        this.behavior = 'tracking';
                        this.fireRate = 85;
                        break;
                        
                    case 'bomber':
                        this.health = 95;
                        this.maxHealth = 95;
                        this.damage = 26;
                        this.score = 300;
                        this.size = 110;
                        this.behavior = 'slow';
                        this.fireRate = 150;
                        break;
                        
                    case 'turret':
                        this.health = 80;
                        this.maxHealth = 80;
                        this.damage = 24;
                        this.score = 250;
                        this.size = 86;
                        this.behavior = 'stationary';
                        this.fireRate = 75;
                        break;
                        
                    case 'boss':
                        this.health = 900;
                        this.maxHealth = 900;
                        this.damage = 38;
                        this.score = 2000;
                        this.size = 270; // 约为玩家直升机 3 倍
                        this.behavior = 'boss';
                        this.fireRate = 30;
                        break;
                }
            }

            spawn(x, y) {
                this.position = new Vector2(x, y);
                this.active = true;
                this.age = 0;
                this.fireCooldown = 0;
            }

            update(dt) {
                if (!this.active) return;
                
                this.age += dt;
                const t = this.age * 0.03 + this.phaseOffset;
                
                // 行为逻辑
                switch (this.behavior) {
                    case 'straight':
                        // 无人机：低精度锁定直升机周边（误差最大）
                        {
                            const target = game.helicopter.position.add(new Vector2(
                                -180 + Math.sin(t * 0.8) * 90,
                                Math.cos(t * 1.1) * 110
                            ));
                            const desired = target.sub(this.position).normalize().mul(2.8);
                            this.velocity = this.velocity.mul(0.86).add(desired.mul(0.14));
                        }
                        break;
                        
                    case 'tracking':
                        // 战斗机：中精度锁定，围绕目标侧后方机动
                        {
                            const fighterTarget = game.helicopter.position.add(new Vector2(
                                -95 + Math.sin(t * 1.2) * 38,
                                Math.cos(t * 1.55) * 46
                            ));
                            const toFighterTarget = fighterTarget.sub(this.position);
                            const dist = toFighterTarget.length();
                            if (dist > 0) {
                                const desired = toFighterTarget.normalize().mul(3.1);
                                this.velocity = this.velocity.mul(0.83).add(desired.mul(0.17));
                            }
                        }
                        break;
                        
                    case 'slow':
                        // 轰炸机：较高精度锁定，保持距离后进行扇形压制
                        {
                            const bomberTarget = game.helicopter.position.add(new Vector2(
                                -150 + Math.sin(t * 0.7) * 26,
                                Math.cos(t * 0.9) * 28
                            ));
                            const desired = bomberTarget.sub(this.position).normalize().mul(1.55);
                            this.velocity = this.velocity.mul(0.9).add(desired.mul(0.1));
                        }
                        break;
                        
                    case 'stationary':
                        // 武装直升机：高精度锁定，在玩家周边悬停狙击
                        {
                            const hoverX = game.helicopter.position.x + 180 + Math.sin(t * 0.7) * 22;
                            const hoverY = game.helicopter.position.y + Math.sin(t * 1.35) * 40;
                            const toHoverPoint = new Vector2(hoverX, hoverY).sub(this.position);
                            this.velocity = toHoverPoint.mul(0.08);
                        }
                        break;
                        
                    case 'boss':
                        // Boss 移动模式
                        const bossPhase = Math.floor(this.age / 300) % 3;
                        switch (bossPhase) {
                            case 0:
                                this.velocity = game.helicopter.position.add(new Vector2(260, Math.sin(t) * 70))
                                    .sub(this.position).normalize().mul(1.9);
                                break;
                            case 1:
                                this.velocity = game.helicopter.position.add(new Vector2(220, Math.cos(t * 1.3) * 95))
                                    .sub(this.position).normalize().mul(1.7);
                                break;
                            case 2:
                                const toBossPlayer = game.helicopter.position.sub(this.position);
                                this.velocity = toBossPlayer.normalize().mul(2.2);
                                break;
                        }
                        break;
                }
                
                this.position = this.position.add(this.velocity.mul(dt));
                if (this.velocity.length() > 0.05) {
                    const targetRot = Math.atan2(this.velocity.y, this.velocity.x);
                    this.rotation += (targetRot - this.rotation) * 0.18;
                }
                
                // 射击逻辑
                this.fireCooldown -= dt;
                if (this.fireCooldown <= 0 && this.behavior !== 'straight') {
                    this.fire();
                    this.fireCooldown = this.fireRate;
                }
                
                // 边界检查
                if (this.position.x < -100 || this.position.x > game.canvas.width + 100 ||
                    this.position.y < -100 || this.position.y > game.canvas.height + 100) {
                    this.active = false;
                }
            }

            fire() {
                const toPlayer = game.helicopter.position.sub(this.position);
                const baseAngle = Math.atan2(toPlayer.y, toPlayer.x);

                const fireAt = (angle, speed, damageScale = 1) => {
                    game.bullets.spawn(
                        this.position.x,
                        this.position.y,
                        Math.cos(angle) * speed,
                        Math.sin(angle) * speed,
                        this.damage * damageScale,
                        'normal',
                        'enemy'
                    );
                };

                switch (this.type) {
                    case 'drone':
                        // 轻火力点射
                        fireAt(baseAngle + (Math.random() - 0.5) * 0.12, 5.4, 0.85);
                        break;
                    case 'fighter':
                        // 双联机炮短点
                        fireAt(baseAngle - 0.08, 6.4, 0.75);
                        fireAt(baseAngle + 0.08, 6.4, 0.75);
                        break;
                    case 'bomber':
                        // 低速重弹扇形压制
                        fireAt(baseAngle - 0.22, 4.4, 0.8);
                        fireAt(baseAngle, 4.2, 1.05);
                        fireAt(baseAngle + 0.22, 4.4, 0.8);
                        break;
                    case 'turret':
                        // 稳定精准射击
                        fireAt(baseAngle, 6.1, 1);
                        break;
                    case 'boss':
                        // 多模式弹幕
                        if (this.volleyIndex % 3 === 0) {
                            for (let i = -2; i <= 2; i++) {
                                fireAt(baseAngle + i * 0.12, 5.2, 0.7);
                            }
                        } else if (this.volleyIndex % 3 === 1) {
                            for (let i = 0; i < 8; i++) {
                                fireAt((Math.PI * 2 / 8) * i, 4.4, 0.55);
                            }
                        } else {
                            fireAt(baseAngle, 7.1, 1.2);
                        }
                        this.volleyIndex++;
                        break;
                    default:
                        fireAt(baseAngle, 5, 1);
                }
            }

            takeDamage(damage) {
                this.health -= damage;
                
                // 受击效果
                const hitFxByType = {
                    drone: { count: 9, color: '#7fc8ff', size: 2.2, speed: 4.8, type: 'spark' },
                    fighter: { count: 7, color: '#ffb078', size: 2.4, speed: 4.2, type: 'spark' },
                    bomber: { count: 10, color: '#a8a8a8', size: 3.1, speed: 3.4, type: 'smoke' },
                    turret: { count: 8, color: '#d8e6ef', size: 2.5, speed: 3.8, type: 'spark' },
                    boss: { count: 14, color: '#ff8c70', size: 3.4, speed: 4.6, type: 'spark' }
                };
                const fx = hitFxByType[this.type] || hitFxByType.fighter;
                game.particles.emit(this.position.x, this.position.y, fx.count, {
                    color: fx.color,
                    size: fx.size,
                    speed: fx.speed,
                    life: 20,
                    type: fx.type
                });
                
                if (this.health <= 0) {
                    this.destroy();
                }
            }

            destroy() {
                this.active = false;
                
                // 爆炸效果
                game.particles.emitExplosion(this.position.x, this.position.y, this.size / 30);

                // 类型化击毁反馈
                switch (this.type) {
                    case 'drone':
                        game.particles.emit(this.position.x, this.position.y, 16, {
                            color: '#8fd8ff',
                            speed: 5.5,
                            life: 20,
                            size: 1.8,
                            type: 'spark'
                        });
                        break;
                    case 'fighter':
                        game.particles.emit(this.position.x, this.position.y, 14, {
                            color: '#c9d2d8',
                            speed: 4.6,
                            life: 22,
                            size: 2.4,
                            type: 'spark'
                        });
                        game.particles.emit(this.position.x, this.position.y, 10, {
                            color: '#6a6e72',
                            speed: 2.2,
                            life: 30,
                            size: 3.2,
                            type: 'smoke'
                        });
                        break;
                    case 'bomber':
                        game.particles.emitExplosion(this.position.x, this.position.y, 2);
                        game.particles.emit(this.position.x, this.position.y, 24, {
                            color: '#76797d',
                            speed: 3.2,
                            life: 36,
                            size: 4.2,
                            type: 'smoke'
                        });
                        game.screenShake = Math.max(game.screenShake, 10);
                        break;
                    case 'turret':
                        game.particles.emit(this.position.x, this.position.y, 20, {
                            color: '#e5f1f8',
                            speed: 5.2,
                            life: 24,
                            size: 2.2,
                            type: 'spark'
                        });
                        game.particles.emit(this.position.x, this.position.y, 8, {
                            color: '#5f666c',
                            speed: 2.8,
                            life: 30,
                            size: 3.2,
                            type: 'smoke'
                        });
                        break;
                    case 'boss':
                        game.particles.emitExplosion(this.position.x - 40, this.position.y - 20, 1.5);
                        game.particles.emitExplosion(this.position.x + 30, this.position.y + 15, 1.4);
                        game.particles.emit(this.position.x, this.position.y, 40, {
                            color: '#ff9e7a',
                            speed: 6.2,
                            life: 30,
                            size: 3,
                            type: 'spark'
                        });
                        game.screenShake = Math.max(game.screenShake, 14);
                        break;
                }
                
                // 加分
                game.addScore(this.score);
                
                // 连击
                game.addCombo();
                
                // 音效
                game.audio.playSound('explosion');
                
                // 掉落道具
                if (Math.random() < 0.2) {
                    game.spawnPowerUp(this.position.x, this.position.y);
                }
                
                // Boss 死亡特殊处理
                if (this.type === 'boss') {
                    game.bossDefeated();
                }
            }

            render(ctx) {
                if (!this.active) return;
                
                ctx.save();
                ctx.translate(this.position.x, this.position.y);
                ctx.rotate(this.rotation);
                
                // 根据类型渲染不同的敌人
                switch (this.type) {
                    case 'drone':
                        this.renderDrone(ctx);
                        break;
                    case 'fighter':
                        this.renderFighter(ctx);
                        break;
                    case 'bomber':
                        this.renderBomber(ctx);
                        break;
                    case 'turret':
                        this.renderTurret(ctx);
                        break;
                    case 'boss':
                        this.renderBoss(ctx);
                        break;
                }
                
                ctx.restore();
            }

            renderDrone(ctx) {
                const s = this.size / 45;
                ctx.save();
                ctx.scale(s, s);
                // 侦察攻击无人机（四旋翼+机鼻）
                ctx.fillStyle = '#4c5661';
                ctx.beginPath();
                ctx.ellipse(0, 0, 14, 8, 0, 0, Math.PI * 2);
                ctx.fill();

                ctx.fillStyle = '#2f343b';
                ctx.beginPath();
                ctx.moveTo(14, 0);
                ctx.lineTo(22, -4);
                ctx.lineTo(22, 4);
                ctx.closePath();
                ctx.fill();

                ctx.strokeStyle = '#616b76';
                ctx.lineWidth = 2;
                ctx.beginPath();
                ctx.moveTo(-6, -4);
                ctx.lineTo(-14, -12);
                ctx.moveTo(-6, 4);
                ctx.lineTo(-14, 12);
                ctx.moveTo(6, -4);
                ctx.lineTo(14, -12);
                ctx.moveTo(6, 4);
                ctx.lineTo(14, 12);
                ctx.stroke();

                ctx.fillStyle = '#aab3bc';
                ctx.fillRect(-16, -13, 5, 2);
                ctx.fillRect(-16, 11, 5, 2);
                ctx.fillRect(11, -13, 5, 2);
                ctx.fillRect(11, 11, 5, 2);
                ctx.restore();
            }

            renderFighter(ctx) {
                const s = this.size / 72;
                ctx.save();
                ctx.scale(s, s);
                // 空优战斗机
                const grad = ctx.createLinearGradient(-24, 0, 24, 0);
                grad.addColorStop(0, '#49525d');
                grad.addColorStop(1, '#2f3742');
                ctx.fillStyle = grad;
                ctx.beginPath();
                ctx.moveTo(27, 0);
                ctx.lineTo(6, -7);
                ctx.lineTo(-20, -8);
                ctx.lineTo(-26, -3);
                ctx.lineTo(-26, 3);
                ctx.lineTo(-20, 8);
                ctx.lineTo(6, 7);
                ctx.closePath();
                ctx.fill();

                // 三角主翼
                ctx.fillStyle = '#3b4550';
                ctx.beginPath();
                ctx.moveTo(-2, -5);
                ctx.lineTo(-15, -17);
                ctx.lineTo(-4, -3);
                ctx.closePath();
                ctx.fill();
                
                ctx.beginPath();
                ctx.moveTo(-2, 5);
                ctx.lineTo(-15, 17);
                ctx.lineTo(-4, 3);
                ctx.closePath();
                ctx.fill();

                // 座舱
                ctx.fillStyle = '#87a8bf';
                ctx.beginPath();
                ctx.ellipse(8, -1, 6, 3.5, 0, 0, Math.PI * 2);
                ctx.fill();

                // 尾翼
                ctx.fillStyle = '#2a313a';
                ctx.fillRect(-24, -10, 4, 8);
                ctx.fillRect(-24, 2, 4, 8);
                ctx.restore();
            }

            renderBomber(ctx) {
                const s = this.size / 110;
                ctx.save();
                ctx.scale(s, s);
                // 重型轰炸机
                const bodyGrad = ctx.createLinearGradient(-32, 0, 32, 0);
                bodyGrad.addColorStop(0, '#4e5458');
                bodyGrad.addColorStop(1, '#30363a');
                ctx.fillStyle = bodyGrad;
                ctx.beginPath();
                ctx.ellipse(0, 0, 30, 14, 0, 0, Math.PI * 2);
                ctx.fill();

                // 厚翼
                ctx.fillStyle = '#3c4246';
                ctx.fillRect(-10, -20, 18, 8);
                ctx.fillRect(-10, 12, 18, 8);

                // 发动机舱
                ctx.fillStyle = '#262c30';
                ctx.fillRect(-2, -18, 8, 5);
                ctx.fillRect(-2, 13, 8, 5);

                // 炸弹仓
                ctx.fillStyle = '#1f2428';
                ctx.fillRect(8, -4, 14, 8);

                // 目标指示灯
                ctx.fillStyle = '#d9805f';
                ctx.beginPath();
                ctx.arc(24, 0, 3, 0, Math.PI * 2);
                ctx.fill();
                ctx.restore();
            }

            renderTurret(ctx) {
                const s = this.size / 86;
                ctx.save();
                ctx.scale(s, s);
                // 武装直升机（悬停火力点）
                ctx.fillStyle = '#56616a';
                ctx.beginPath();
                ctx.moveTo(22, 0);
                ctx.lineTo(6, -8);
                ctx.lineTo(-16, -10);
                ctx.lineTo(-24, -4);
                ctx.lineTo(-24, 4);
                ctx.lineTo(-16, 10);
                ctx.lineTo(6, 8);
                ctx.closePath();
                ctx.fill();

                // 座舱
                ctx.fillStyle = '#7e9aae';
                ctx.beginPath();
                ctx.ellipse(8, -2, 8, 4.5, 0, 0, Math.PI * 2);
                ctx.fill();

                // 主旋翼
                ctx.save();
                ctx.rotate(this.age * 0.22);
                ctx.fillStyle = '#2f3942';
                ctx.fillRect(-24, -1.5, 48, 3);
                ctx.restore();

                // 尾梁
                ctx.fillStyle = '#3e4852';
                ctx.fillRect(-24, -2, 16, 4);

                // 炮管指向玩家
                ctx.fillStyle = '#222a31';
                ctx.save();
                const toPlayer = game.helicopter.position.sub(this.position);
                const angle = Math.atan2(toPlayer.y, toPlayer.x) - this.rotation;
                ctx.rotate(angle);
                ctx.fillRect(10, -2.5, 16, 5);
                ctx.restore();
                ctx.restore();
            }

            renderBoss(ctx) {
                const s = this.size / 270;
                ctx.save();
                ctx.scale(s, s);
                // Boss 主体
                const gradient = ctx.createRadialGradient(0, 0, 0, 0, 0, 135);
                gradient.addColorStop(0, '#ff0000');
                gradient.addColorStop(0.5, '#8b0000');
                gradient.addColorStop(1, '#4a0000');
                
                ctx.fillStyle = gradient;
                ctx.beginPath();
                ctx.ellipse(0, 0, 135, 108, 0, 0, Math.PI * 2);
                ctx.fill();
                
                // Boss 眼睛
                ctx.fillStyle = '#ffff00';
                ctx.beginPath();
                ctx.arc(56, -26, 18, 0, Math.PI * 2);
                ctx.arc(56, 26, 18, 0, Math.PI * 2);
                ctx.fill();
                
                // Boss 纹理
                ctx.strokeStyle = '#660000';
                ctx.lineWidth = 2;
                for (let i = 0; i < 5; i++) {
                    ctx.beginPath();
                    ctx.arc(0, 0, 42 + i * 18, 0, Math.PI * 2);
                    ctx.stroke();
                }
                
                // 血条
                const healthPercent = this.health / this.maxHealth;
                ctx.fillStyle = '#333333';
                ctx.fillRect(-108, -158, 216, 16);
                ctx.fillStyle = healthPercent > 0.5 ? '#00ff00' : healthPercent > 0.25 ? '#ffff00' : '#ff0000';
                ctx.fillRect(-108, -158, 216 * healthPercent, 16);
                ctx.restore();
            }

            getBounds() {
                return {
                    x: this.position.x - this.size / 2,
                    y: this.position.y - this.size / 2,
                    width: this.size,
                    height: this.size
                };
            }
        }

        /**
         * 敌人管理器
         * Enemy Manager
         */
        class EnemyManager {
            constructor() {
                this.enemies = [];
                this.pool = new ObjectPool(() => new Enemy(), 50);
                
                this.wave = 1;
                this.waveTime = 0;
                this.enemiesSpawned = 0;
                this.enemiesKilled = 0;
                this.waveEnemyCount = 10;
                
                this.bossActive = false;
            }

            spawnEnemy(type = 'drone') {
                const enemy = this.pool.get();
                enemy.type = type;
                enemy.setupType();
                
                const x = game.canvas.width + 50;
                const y = Math.random() * (game.canvas.height - 100) + 50;
                
                enemy.spawn(x, y);
                this.enemies.push(enemy);
                this.enemiesSpawned++;
            }

            spawnBoss() {
                this.bossActive = true;
                const boss = this.pool.get();
                boss.type = 'boss';
                boss.setupType();
                
                boss.spawn(game.canvas.width + 100, game.canvas.height / 2);
                this.enemies.push(boss);
                
                // 显示 Boss 血条
                document.getElementById('bossHealthContainer').classList.add('show');
            }

            update(dt) {
                // 波次管理
                this.waveTime += dt;
                
                if (!this.bossActive) {
                    // 普通波次
                    const spawnInterval = Math.max(500, CONFIG.ENEMY_SPAWN_RATE - this.wave * 100);
                    
                    if (this.enemiesSpawned < this.waveEnemyCount && 
                        this.waveTime > spawnInterval) {
                        this.spawnWaveEnemy();
                        this.waveTime = 0;
                    }
                    
                    // 检查波次是否完成
                    if (this.enemiesSpawned >= this.waveEnemyCount && this.enemies.length === 0) {
                        this.nextWave();
                    }
                }
                
                // 更新敌人
                for (let i = this.enemies.length - 1; i >= 0; i--) {
                    const enemy = this.enemies[i];
                    enemy.update(dt);
                    
                    if (!enemy.active) {
                        this.enemies.splice(i, 1);
                        this.pool.release(enemy);
                        this.enemiesKilled++;
                    }
                }
                
                // 更新 Boss 血条
                if (this.bossActive) {
                    const boss = this.enemies.find(e => e.type === 'boss');
                    if (boss) {
                        const healthPercent = boss.health / boss.maxHealth;
                        document.getElementById('bossHealthFill').style.width = (healthPercent * 100) + '%';
                    }
                }
            }

            spawnWaveEnemy() {
                const rand = Math.random();
                let type = 'drone';
                
                if (this.wave >= 2 && rand < 0.3) type = 'fighter';
                if (this.wave >= 3 && rand < 0.2) type = 'bomber';
                if (this.wave >= 4 && rand < 0.15) type = 'turret';
                
                this.spawnEnemy(type);
            }

            nextWave() {
                this.wave++;
                this.enemiesSpawned = 0;
                this.enemiesKilled = 0;
                this.waveEnemyCount = 10 + this.wave * 2;
                this.waveTime = 0;
                
                // 显示波次提示
                const waveDisplay = document.getElementById('waveDisplay');
                waveDisplay.textContent = `WAVE ${this.wave}`;
                waveDisplay.classList.add('show');
                setTimeout(() => waveDisplay.classList.remove('show'), 2000);
                
                // 更新 HUD
                document.getElementById('waveDisplaySmall').textContent = this.wave;
                
                // Boss 波次
                if (this.wave % CONFIG.BOSS_WAVE_INTERVAL === 0) {
                    this.spawnBoss();
                }
            }

            bossDefeated() {
                this.bossActive = false;
                document.getElementById('bossHealthContainer').classList.remove('show');
                
                // 奖励分数
                game.addScore(5000);
                
                // 胜利检查
                if (this.wave >= 10) {
                    game.victory();
                }
            }

            render(ctx) {
                for (const enemy of this.enemies) {
                    enemy.render(ctx);
                }
            }

            clear() {
                for (const enemy of this.enemies) {
                    this.pool.release(enemy);
                }
                this.enemies = [];
                this.bossActive = false;
                document.getElementById('bossHealthContainer').classList.remove('show');
            }
        }

        /**
         * 地面敌人：肩扛防空导弹兵
         * Ground Enemy: MANPADS soldier
         */
        class GroundSamSoldier {
            constructor() {
                this.position = new Vector2();
                this.active = false;
                this.health = 10;
                this.maxHealth = 10;
                this.size = 28;
                this.score = 350;
                this.fireCooldown = 0;
            }

            spawn(x, y) {
                this.position = new Vector2(x, y);
                this.active = true;
                this.health = this.maxHealth;
                this.fireCooldown = 60;
            }

            update(dt) {
                if (!this.active) return;
                this.fireCooldown -= dt;
                if (this.fireCooldown <= 0) {
                    this.fireSam();
                    this.fireCooldown = 240; // 常驻单位，循环发射
                }
            }

            fireSam() {
                const toPlayer = game.helicopter.position.sub(this.position).normalize();
                game.bullets.spawn(
                    this.position.x + 6,
                    this.position.y - 16,
                    toPlayer.x * 4.2,
                    toPlayer.y * 4.2,
                    55,
                    'sam',
                    'ground'
                );
            }

            takeDamage(damage) {
                if (!this.active) return;
                this.health -= damage;
                game.particles.emit(this.position.x, this.position.y - 12, 7, {
                    color: '#e6d8c6',
                    speed: 2.8,
                    life: 18,
                    size: 2.2,
                    type: 'spark'
                });

                if (this.health <= 0) {
                    this.active = false;
                    game.addScore(this.score);
                    game.addCombo();
                    game.particles.emit(this.position.x, this.position.y - 8, 18, {
                        color: '#bda48a',
                        speed: 3.8,
                        life: 22,
                        size: 2.6,
                        type: 'spark'
                    });
                }
            }

            render(ctx) {
                if (!this.active) return;

                const x = this.position.x;
                const y = this.position.y;

                // 低矮民房墙体 + 沙袋掩体（无窗）
                ctx.fillStyle = '#d9cfbf';
                ctx.fillRect(x - 34, y - 32, 68, 32);
                ctx.fillStyle = '#9a7358';
                ctx.beginPath();
                ctx.moveTo(x - 38, y - 32);
                ctx.lineTo(x, y - 54);
                ctx.lineTo(x + 38, y - 32);
                ctx.closePath();
                ctx.fill();

                // 沙袋
                ctx.fillStyle = '#b69f82';
                for (let i = -3; i <= 3; i++) {
                    ctx.beginPath();
                    ctx.ellipse(x + i * 8, y - 7, 6.2, 3.8, 0, 0, Math.PI * 2);
                    ctx.fill();
                }

                // 人类跪姿（写实化轮廓）
                ctx.save();
                ctx.translate(x - 3, y - 14);
                ctx.scale(1.18, 1.18);

                // 头部
                ctx.fillStyle = '#d2b49a';
                ctx.beginPath();
                ctx.arc(-5, -9, 4.3, 0, Math.PI * 2);
                ctx.fill();

                // 头盔
                ctx.fillStyle = '#4f5b45';
                ctx.beginPath();
                ctx.arc(-5, -10.5, 5.2, Math.PI, Math.PI * 2);
                ctx.fill();

                // 上身（前倾）
                ctx.fillStyle = '#56664b';
                ctx.beginPath();
                ctx.moveTo(-12, -4);
                ctx.lineTo(3, -8);
                ctx.lineTo(10, -2);
                ctx.lineTo(3, 3);
                ctx.lineTo(-10, 4);
                ctx.closePath();
                ctx.fill();

                // 战术背包
                ctx.fillStyle = '#3f4938';
                ctx.fillRect(-13, -5, 5, 8);

                // 跪姿腿部与小腿
                ctx.fillStyle = '#3e4737';
                ctx.fillRect(-10, 3, 10, 4);
                ctx.fillRect(-2, 6, 10, 3.5);
                ctx.fillStyle = '#2f362c';
                ctx.fillRect(7, 6.5, 4.8, 2.8);

                // 肩扛发射筒
                ctx.fillStyle = '#2f343a';
                ctx.fillRect(3, -12, 24, 5);
                ctx.fillStyle = '#656d76';
                ctx.fillRect(24, -11.3, 5, 3.6);
                ctx.fillStyle = '#4d555e';
                ctx.fillRect(2, -10.2, 4, 2.2); // 肩托
                ctx.restore();
            }

            getBounds() {
                return {
                    x: this.position.x - this.size,
                    y: this.position.y - 56,
                    width: this.size * 2,
                    height: 56
                };
            }
        }

        class GroundGunTruck {
            constructor() {
                this.position = new Vector2();
                this.active = false;
                this.health = 45;
                this.maxHealth = 45;
                this.score = 500;
                this.size = 44;
                this.fireCooldown = 0;
                this.turretAngle = -Math.PI / 4;
            }

            spawn(x, y) {
                this.position = new Vector2(x, y);
                this.active = true;
                this.health = this.maxHealth;
                this.fireCooldown = 120;
            }

            update(dt) {
                if (!this.active) return;

                // 向直升机下方区域机动
                const targetX = game.helicopter.position.x + 60;
                const dx = targetX - this.position.x;
                this.position.x += Math.max(-1.8, Math.min(1.8, dx * 0.02)) * dt;
                this.position.x = Math.max(70, Math.min(game.canvas.width - 70, this.position.x));

                this.fireCooldown -= dt;
                if (this.fireCooldown <= 0) {
                    this.fireBurst();
                    this.fireCooldown = 150; // 间隔稍长
                }
            }

            fireBurst() {
                const toPlayer = game.helicopter.position.sub(new Vector2(this.position.x, this.position.y - 10));
                const baseAngle = Math.atan2(toPlayer.y, toPlayer.x);
                this.turretAngle = baseAngle;
                const spread = [-0.12, 0, 0.12];
                for (const s of spread) {
                    const a = baseAngle + s;
                    game.bullets.spawn(
                        this.position.x + Math.cos(a) * 20,
                        this.position.y - 16 + Math.sin(a) * 8,
                        Math.cos(a) * 5.4,
                        Math.sin(a) * 5.4,
                        12,
                        'groundmg',
                        'ground'
                    );
                }
            }

            takeDamage(damage) {
                if (!this.active) return;
                this.health -= damage;
                game.particles.emit(this.position.x, this.position.y - 8, 8, {
                    color: '#d7c2a9',
                    speed: 3.2,
                    life: 18,
                    size: 2.2,
                    type: 'spark'
                });
                if (this.health <= 0) {
                    this.active = false;
                    game.addScore(this.score);
                    game.addCombo();
                    game.particles.emitExplosion(this.position.x, this.position.y - 6, 1.2);
                }
            }

            render(ctx) {
                if (!this.active) return;
                const x = this.position.x;
                const y = this.position.y;

                ctx.fillStyle = '#55616d';
                ctx.fillRect(x - 30, y - 16, 60, 14);
                ctx.fillStyle = '#667582';
                ctx.fillRect(x + 16, y - 22, 18, 12);
                ctx.fillStyle = '#8ea2b5';
                ctx.fillRect(x + 8, y - 24, 12, 8);
                ctx.fillStyle = '#4a5662';
                ctx.fillRect(x - 24, y - 24, 30, 10);
                ctx.fillStyle = '#2a2f35';
                ctx.beginPath();
                ctx.arc(x - 18, y, 5.5, 0, Math.PI * 2);
                ctx.arc(x + 16, y, 5.5, 0, Math.PI * 2);
                ctx.fill();

                ctx.save();
                ctx.translate(x - 8, y - 22);
                ctx.rotate(this.turretAngle);
                ctx.fillStyle = '#30363d';
                ctx.fillRect(-4, -3, 8, 6);
                ctx.fillStyle = '#1f252c';
                ctx.fillRect(0, -2, 18, 4);
                ctx.restore();
            }

            getBounds() {
                return {
                    x: this.position.x - this.size,
                    y: this.position.y - 30,
                    width: this.size * 2,
                    height: 30
                };
            }
        }

        class GroundEnemyManager {
            constructor() {
                this.enemies = [];
                this.soldierPool = new ObjectPool(() => new GroundSamSoldier(), 6);
                this.truckPool = new ObjectPool(() => new GroundGunTruck(), 4);
                this.spawnTimer = 0;
                this.spawnInterval = 780;
                this.maxActive = 3;
            }

            update(dt) {
                this.spawnTimer += dt;
                if (this.spawnTimer >= this.spawnInterval) {
                    this.trySpawn();
                    this.spawnTimer = 0;
                }

                for (let i = this.enemies.length - 1; i >= 0; i--) {
                    const e = this.enemies[i];
                    e.update(dt);
                    if (!e.active) {
                        this.enemies.splice(i, 1);
                        if (e instanceof GroundGunTruck) this.truckPool.release(e);
                        else this.soldierPool.release(e);
                    }
                }
            }

            trySpawn() {
                if (this.enemies.length >= this.maxActive) return;
                if (Math.random() > 0.42) return; // 稀疏刷新

                const spawnTruck = Math.random() < 0.35;
                const x = game.canvas.width * (0.56 + Math.random() * 0.38);
                const y = game.canvas.height - 68;
                if (spawnTruck) {
                    const truck = this.truckPool.get();
                    truck.spawn(x, y);
                    this.enemies.push(truck);
                } else {
                    const soldier = this.soldierPool.get();
                    soldier.spawn(x, y);
                    this.enemies.push(soldier);
                }
            }

            render(ctx) {
                for (const e of this.enemies) {
                    e.render(ctx);
                }
            }

            clear() {
                for (const e of this.enemies) {
                    if (e instanceof GroundGunTruck) this.truckPool.release(e);
                    else this.soldierPool.release(e);
                }
                this.enemies = [];
                this.spawnTimer = 0;
            }
        }

        /**
         * 道具类
         * Power-up Class
         */
        class PowerUp {
            constructor() {
                this.position = new Vector2();
                this.velocity = new Vector2();
                this.type = 'health';
                this.active = false;
                this.size = 20;
            }

            spawn(x, y, type = 'health') {
                this.position = new Vector2(x, y);
                this.velocity = new Vector2(-2, 0);
                this.type = type;
                this.active = true;
            }

            update(dt) {
                if (!this.active) return;
                
                this.position = this.position.add(this.velocity.mul(dt));
                
                // 边界检查
                if (this.position.x < -50) {
                    this.active = false;
                }
            }

            render(ctx) {
                if (!this.active) return;
                
                ctx.save();
                ctx.translate(this.position.x, this.position.y);
                
                // 闪烁效果
                const alpha = 0.5 + Math.sin(Date.now() * 0.01) * 0.5;
                ctx.globalAlpha = alpha;
                
                switch (this.type) {
                    case 'health':
                        ctx.fillStyle = '#ff4444';
                        ctx.beginPath();
                        ctx.arc(0, -5, 8, 0, Math.PI * 2);
                        ctx.arc(0, 5, 8, 0, Math.PI * 2);
                        ctx.fill();
                        ctx.fillStyle = '#ffffff';
                        ctx.fillRect(-3, -10, 6, 20);
                        ctx.fillRect(-10, -3, 20, 6);
                        break;
                        
                    case 'energy':
                        ctx.fillStyle = '#4444ff';
                        ctx.beginPath();
                        ctx.moveTo(0, -12);
                        ctx.lineTo(10, 0);
                        ctx.lineTo(0, 12);
                        ctx.lineTo(-10, 0);
                        ctx.closePath();
                        ctx.fill();
                        break;
                        
                    case 'shield':
                        ctx.fillStyle = '#44ffff';
                        ctx.beginPath();
                        ctx.arc(0, 0, 12, 0, Math.PI * 2);
                        ctx.fill();
                        ctx.strokeStyle = '#ffffff';
                        ctx.lineWidth = 2;
                        ctx.stroke();
                        break;
                        
                    case 'weapon':
                        ctx.fillStyle = '#ffaa00';
                        ctx.font = '20px Arial';
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'middle';
                        ctx.fillText('W', 0, 0);
                        break;
                }
                
                ctx.restore();
            }

            collect() {
                this.active = false;
                
                switch (this.type) {
                    case 'health':
                        game.helicopter.health = Math.min(
                            game.helicopter.maxHealth,
                            game.helicopter.health + 30
                        );
                        break;
                    case 'energy':
                        game.helicopter.energy = Math.min(
                            game.helicopter.maxEnergy,
                            game.helicopter.energy + 50
                        );
                        break;
                    case 'shield':
                        game.helicopter.shield = Math.min(
                            game.helicopter.maxShield,
                            game.helicopter.shield + 30
                        );
                        break;
                    case 'weapon':
                        // 武器升级
                        game.helicopter.currentWeapon = (game.helicopter.currentWeapon + 1) % 4;
                        game.helicopter.updateWeaponUI();
                        break;
                }
                
                game.audio.playSound('powerup');
            }

            getBounds() {
                return {
                    x: this.position.x - this.size / 2,
                    y: this.position.y - this.size / 2,
                    width: this.size,
                    height: this.size
                };
            }
        }

        /**
         * 道具管理器
         * Power-up Manager
         */
        class PowerUpManager {
            constructor() {
                this.powerUps = [];
                this.pool = new ObjectPool(() => new PowerUp(), 20);
            }

            spawn(x, y) {
                const types = ['health', 'energy', 'shield', 'weapon'];
                const type = types[Math.floor(Math.random() * types.length)];
                
                const powerUp = this.pool.get();
                powerUp.spawn(x, y, type);
                this.powerUps.push(powerUp);
            }

            update(dt) {
                for (let i = this.powerUps.length - 1; i >= 0; i--) {
                    const powerUp = this.powerUps[i];
                    powerUp.update(dt);
                    
                    if (!powerUp.active) {
                        this.powerUps.splice(i, 1);
                        this.pool.release(powerUp);
                    }
                }
            }

            render(ctx) {
                for (const powerUp of this.powerUps) {
                    powerUp.render(ctx);
                }
            }

            checkCollision(helicopter) {
                for (const powerUp of this.powerUps) {
                    if (!powerUp.active) continue;
                    
                    const bounds = powerUp.getBounds();
                    const heliBounds = helicopter.getBounds();
                    
                    if (this.checkAABB(bounds, heliBounds)) {
                        powerUp.collect();
                    }
                }
            }

            checkAABB(a, b) {
                return a.x < b.x + b.width &&
                       a.x + a.width > b.x &&
                       a.y < b.y + b.height &&
                       a.y + a.height > b.y;
            }

            clear() {
                for (const powerUp of this.powerUps) {
                    this.pool.release(powerUp);
                }
                this.powerUps = [];
            }
        }

        /**
         * 音频管理器
         * Audio Manager
         */
        class AudioManager {
            constructor() {
                this.audioContext = null;
                this.sounds = {};
                this.initialized = false;
            }

            init() {
                if (this.initialized) return;
                
                try {
                    this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
                    this.initialized = true;
                } catch (e) {
                    console.warn('Web Audio API not supported');
                }
            }

            playSound(type) {
                if (!this.initialized) return;
                
                const oscillator = this.audioContext.createOscillator();
                const gainNode = this.audioContext.createGain();
                
                oscillator.connect(gainNode);
                gainNode.connect(this.audioContext.destination);
                
                switch (type) {
                    case 'shoot':
                        oscillator.frequency.setValueAtTime(800, this.audioContext.currentTime);
                        oscillator.frequency.exponentialRampToValueAtTime(200, this.audioContext.currentTime + 0.1);
                        gainNode.gain.setValueAtTime(0.1, this.audioContext.currentTime);
                        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.1);
                        oscillator.start(this.audioContext.currentTime);
                        oscillator.stop(this.audioContext.currentTime + 0.1);
                        break;
                        
                    case 'missile':
                        oscillator.frequency.setValueAtTime(200, this.audioContext.currentTime);
                        oscillator.frequency.exponentialRampToValueAtTime(100, this.audioContext.currentTime + 0.3);
                        gainNode.gain.setValueAtTime(0.15, this.audioContext.currentTime);
                        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.3);
                        oscillator.start(this.audioContext.currentTime);
                        oscillator.stop(this.audioContext.currentTime + 0.3);
                        break;
                        
                    case 'plasma':
                        oscillator.type = 'sine';
                        oscillator.frequency.setValueAtTime(400, this.audioContext.currentTime);
                        oscillator.frequency.exponentialRampToValueAtTime(800, this.audioContext.currentTime + 0.15);
                        gainNode.gain.setValueAtTime(0.1, this.audioContext.currentTime);
                        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.15);
                        oscillator.start(this.audioContext.currentTime);
                        oscillator.stop(this.audioContext.currentTime + 0.15);
                        break;
                        
                    case 'explosion':
                        oscillator.type = 'sawtooth';
                        oscillator.frequency.setValueAtTime(100, this.audioContext.currentTime);
                        oscillator.frequency.exponentialRampToValueAtTime(30, this.audioContext.currentTime + 0.4);
                        gainNode.gain.setValueAtTime(0.2, this.audioContext.currentTime);
                        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.4);
                        oscillator.start(this.audioContext.currentTime);
                        oscillator.stop(this.audioContext.currentTime + 0.4);
                        break;
                        
                    case 'hit':
                        oscillator.type = 'square';
                        oscillator.frequency.setValueAtTime(200, this.audioContext.currentTime);
                        oscillator.frequency.exponentialRampToValueAtTime(50, this.audioContext.currentTime + 0.1);
                        gainNode.gain.setValueAtTime(0.1, this.audioContext.currentTime);
                        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.1);
                        oscillator.start(this.audioContext.currentTime);
                        oscillator.stop(this.audioContext.currentTime + 0.1);
                        break;
                        
                    case 'powerup':
                        oscillator.type = 'sine';
                        oscillator.frequency.setValueAtTime(400, this.audioContext.currentTime);
                        oscillator.frequency.exponentialRampToValueAtTime(800, this.audioContext.currentTime + 0.2);
                        gainNode.gain.setValueAtTime(0.1, this.audioContext.currentTime);
                        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.2);
                        oscillator.start(this.audioContext.currentTime);
                        oscillator.stop(this.audioContext.currentTime + 0.2);
                        break;
                        
                    case 'shield':
                        oscillator.type = 'sine';
                        oscillator.frequency.setValueAtTime(600, this.audioContext.currentTime);
                        oscillator.frequency.exponentialRampToValueAtTime(300, this.audioContext.currentTime + 0.3);
                        gainNode.gain.setValueAtTime(0.1, this.audioContext.currentTime);
                        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.3);
                        oscillator.start(this.audioContext.currentTime);
                        oscillator.stop(this.audioContext.currentTime + 0.3);
                        break;
                    case 'lock':
                        oscillator.type = 'triangle';
                        oscillator.frequency.setValueAtTime(520, this.audioContext.currentTime);
                        oscillator.frequency.linearRampToValueAtTime(760, this.audioContext.currentTime + 0.08);
                        gainNode.gain.setValueAtTime(0.07, this.audioContext.currentTime);
                        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.1);
                        oscillator.start(this.audioContext.currentTime);
                        oscillator.stop(this.audioContext.currentTime + 0.1);
                        break;
                }
            }
        }

        /**
         * 背景类 - 视差滚动
         * Background Class - Parallax Scrolling
         */
        class Background {
            constructor() {
                this.layers = [];
                this.sunX = 180;
                this.sunY = 120;
                this.setupLayers();
            }

            setupLayers() {
                // 远景丘陵
                this.layers.push({
                    speed: 0.12,
                    color: '#7fae7a',
                    hills: this.generateHills(7, 0.5, 360, 680)
                });
                
                // 中景山丘
                this.layers.push({
                    speed: 0.28,
                    color: '#6d9d63',
                    hills: this.generateHills(6, 0.72, 320, 620)
                });
                
                // 农田分块
                this.layers.push({
                    speed: 0.5,
                    fields: this.generateFields(14)
                });

                // 远处河道
                this.layers.push({
                    speed: 0.4,
                    rivers: this.generateRivers(2)
                });
                
                // 稀疏民房（风格多样）
                this.layers.push({
                    speed: 0.65,
                    houses: this.generateHouses(6)
                });

                // 树木与灌木
                this.layers.push({
                    speed: 0.85,
                    trees: this.generateTrees(24)
                });

                // 云层（前后两层）
                this.layers.push({
                    speed: 0.18,
                    color: 'rgba(255, 255, 255, 0.55)',
                    clouds: this.generateClouds(15)
                });
                this.layers.push({
                    speed: 0.34,
                    color: 'rgba(255, 255, 255, 0.45)',
                    clouds: this.generateClouds(10)
                });
            }

            generateHills(count, amplitude, minWidth, maxWidth) {
                const hills = [];
                for (let i = 0; i < count; i++) {
                    hills.push({
                        x: i * 480,
                        height: 180 + Math.random() * 260 * amplitude,
                        width: minWidth + Math.random() * (maxWidth - minWidth)
                    });
                }
                return hills;
            }

            generateFields(count) {
                const fields = [];
                for (let i = 0; i < count; i++) {
                    fields.push({
                        x: i * 220,
                        width: 180 + Math.random() * 120,
                        height: 40 + Math.random() * 35,
                        hue: 70 + Math.random() * 55
                    });
                }
                return fields;
            }

            generateRivers(count) {
                const rivers = [];
                for (let i = 0; i < count; i++) {
                    rivers.push({
                        x: i * 1300 + 500,
                        width: 320 + Math.random() * 180,
                        bend: 18 + Math.random() * 20
                    });
                }
                return rivers;
            }

            generateHouses(count) {
                const houses = [];
                for (let i = 0; i < count; i++) {
                    const style = i % 3;
                    houses.push({
                        x: i * 520 + 220,
                        width: 96 + Math.random() * 44,
                        height: 64 + Math.random() * 36,
                        roofHeight: 18 + Math.random() * 12,
                        style,
                        wallColor: ['#f3ead7', '#e6f0dc', '#f1dfcc'][style],
                        roofColor: ['#bb5a3f', '#88504a', '#8f6b4a'][style]
                    });
                }
                return houses;
            }

            generateTrees(count) {
                const trees = [];
                for (let i = 0; i < count; i++) {
                    trees.push({
                        x: i * 165 + Math.random() * 110,
                        yOffset: Math.random() * 8,
                        size: 16 + Math.random() * 24,
                        trunk: 10 + Math.random() * 10
                    });
                }
                return trees;
            }

            generateClouds(count) {
                const clouds = [];
                for (let i = 0; i < count; i++) {
                    clouds.push({
                        x: Math.random() * 2000,
                        y: 50 + Math.random() * 260,
                        size: 30 + Math.random() * 60,
                        speed: 0.15 + Math.random() * 0.25
                    });
                }
                return clouds;
            }

            update(dt) {
                for (const layer of this.layers) {
                    if (layer.hills) {
                        for (const hill of layer.hills) {
                            hill.x -= layer.speed * dt;
                            if (hill.x + hill.width < -80) {
                                hill.x = game.canvas.width + 120;
                            }
                        }
                    }
                    
                    if (layer.fields) {
                        for (const field of layer.fields) {
                            field.x -= layer.speed * dt;
                            if (field.x + field.width < -120) {
                                field.x = game.canvas.width + 220;
                            }
                        }
                    }

                    if (layer.rivers) {
                        for (const river of layer.rivers) {
                            river.x -= layer.speed * dt;
                            if (river.x + river.width < -180) {
                                river.x = game.canvas.width + 420;
                            }
                        }
                    }

                    if (layer.houses) {
                        for (const house of layer.houses) {
                            house.x -= layer.speed * dt;
                            if (house.x + house.width < -120) {
                                house.x = game.canvas.width + 180 + Math.random() * 180;
                            }
                        }
                    }

                    if (layer.trees) {
                        for (const tree of layer.trees) {
                            tree.x -= layer.speed * dt;
                            if (tree.x + tree.size < -90) {
                                tree.x = game.canvas.width + 120 + Math.random() * 120;
                            }
                        }
                    }
                    
                    if (layer.clouds) {
                        for (const cloud of layer.clouds) {
                            cloud.x -= cloud.speed * dt;
                            if (cloud.x + cloud.size < 0) {
                                cloud.x = game.canvas.width + cloud.size;
                            }
                        }
                    }
                }
            }

            render(ctx) {
                const width = game.canvas.width;
                const height = game.canvas.height;
                const groundTop = height - 70;

                // 傍晚天空渐变
                const sky = ctx.createLinearGradient(0, 0, 0, height);
                sky.addColorStop(0, '#5f7faa');
                sky.addColorStop(0.38, '#7d98ba');
                sky.addColorStop(0.72, '#a9b7c8');
                sky.addColorStop(1, '#c2c8cf');
                ctx.fillStyle = sky;
                ctx.fillRect(0, 0, width, height);

                // 阳光晕染
                const sunGlow = ctx.createRadialGradient(this.sunX, this.sunY, 10, this.sunX, this.sunY, 90);
                sunGlow.addColorStop(0, 'rgba(255, 215, 145, 0.78)');
                sunGlow.addColorStop(1, 'rgba(255, 215, 145, 0)');
                ctx.fillStyle = sunGlow;
                ctx.beginPath();
                ctx.arc(this.sunX, this.sunY, 90, 0, Math.PI * 2);
                ctx.fill();
                ctx.fillStyle = '#f8c988';
                ctx.beginPath();
                ctx.arc(this.sunX, this.sunY, 28, 0, Math.PI * 2);
                ctx.fill();
                
                for (const layer of this.layers) {
                    if (layer.hills) {
                        ctx.fillStyle = layer.color;
                        for (const hill of layer.hills) {
                            ctx.beginPath();
                            ctx.moveTo(hill.x, groundTop + 6);
                            ctx.quadraticCurveTo(
                                hill.x + hill.width * 0.45,
                                groundTop - hill.height,
                                hill.x + hill.width,
                                groundTop + 6
                            );
                            ctx.closePath();
                            ctx.fill();
                        }
                    }
                    
                    if (layer.fields) {
                        for (const field of layer.fields) {
                            const fieldColor = `hsl(${field.hue}, 38%, ${33 + (field.hue - 70) * 0.1}%)`;
                            ctx.fillStyle = fieldColor;
                            ctx.fillRect(
                                field.x,
                                groundTop - field.height + 2,
                                field.width,
                                field.height
                            );

                            // 田垄纹理
                            ctx.strokeStyle = 'rgba(90, 120, 55, 0.28)';
                            ctx.lineWidth = 1;
                            const stripeCount = Math.max(3, Math.floor(field.width / 35));
                            for (let i = 1; i < stripeCount; i++) {
                                const sx = field.x + i * (field.width / stripeCount);
                                ctx.beginPath();
                                ctx.moveTo(sx, groundTop - field.height + 2);
                                ctx.lineTo(sx, groundTop + 2);
                                ctx.stroke();
                            }
                        }
                    }

                    if (layer.rivers) {
                        for (const river of layer.rivers) {
                            const riverY = groundTop - 24;
                            const water = ctx.createLinearGradient(0, riverY - 12, 0, riverY + 22);
                            water.addColorStop(0, '#6e9fb8');
                            water.addColorStop(1, '#4f7d95');
                            ctx.fillStyle = water;

                            ctx.beginPath();
                            ctx.moveTo(river.x, riverY);
                            ctx.quadraticCurveTo(
                                river.x + river.width * 0.3,
                                riverY + river.bend,
                                river.x + river.width * 0.55,
                                riverY + 8
                            );
                            ctx.quadraticCurveTo(
                                river.x + river.width * 0.8,
                                riverY - river.bend * 0.4,
                                river.x + river.width,
                                riverY + 5
                            );
                            ctx.lineTo(river.x + river.width, riverY + 26);
                            ctx.quadraticCurveTo(
                                river.x + river.width * 0.7,
                                riverY + 34,
                                river.x + river.width * 0.42,
                                riverY + 24
                            );
                            ctx.quadraticCurveTo(
                                river.x + river.width * 0.2,
                                riverY + 22,
                                river.x,
                                riverY + 20
                            );
                            ctx.closePath();
                            ctx.fill();

                            // 河面高光
                            ctx.strokeStyle = 'rgba(210, 232, 245, 0.38)';
                            ctx.lineWidth = 1.2;
                            ctx.beginPath();
                            ctx.moveTo(river.x + 12, riverY + 8);
                            ctx.quadraticCurveTo(
                                river.x + river.width * 0.45,
                                riverY + 2,
                                river.x + river.width - 10,
                                riverY + 11
                            );
                            ctx.stroke();
                        }
                    }

                    if (layer.houses) {
                        for (const house of layer.houses) {
                            const baseY = groundTop + 3;
                            // 庭院草坪
                            ctx.fillStyle = '#7ab86a';
                            ctx.fillRect(house.x - 18, groundTop - 8, house.width + 36, 12);

                            // 车道
                            ctx.fillStyle = '#b6b1a8';
                            ctx.fillRect(house.x + house.width * 0.42, baseY, 16, 16);

                            // 围栏
                            ctx.strokeStyle = '#d8d1c3';
                            ctx.lineWidth = 2;
                            ctx.beginPath();
                            ctx.moveTo(house.x - 14, groundTop + 2);
                            ctx.lineTo(house.x + house.width + 14, groundTop + 2);
                            ctx.stroke();
                            for (let fx = house.x - 10; fx < house.x + house.width + 14; fx += 10) {
                                ctx.beginPath();
                                ctx.moveTo(fx, groundTop + 2);
                                ctx.lineTo(fx, groundTop - 6);
                                ctx.stroke();
                            }

                            // 墙体
                            ctx.fillStyle = house.wallColor;
                            ctx.fillRect(house.x, baseY - house.height, house.width, house.height);

                            // 屋顶
                            ctx.fillStyle = house.roofColor;
                            ctx.beginPath();
                            if (house.style === 0) {
                                ctx.moveTo(house.x - 4, baseY - house.height);
                                ctx.lineTo(house.x + house.width / 2, baseY - house.height - house.roofHeight);
                                ctx.lineTo(house.x + house.width + 4, baseY - house.height);
                            } else if (house.style === 1) {
                                ctx.moveTo(house.x - 2, baseY - house.height);
                                ctx.lineTo(house.x + house.width + 2, baseY - house.height);
                                ctx.lineTo(house.x + house.width - 6, baseY - house.height - house.roofHeight);
                                ctx.lineTo(house.x + 6, baseY - house.height - house.roofHeight);
                            } else {
                                ctx.moveTo(house.x - 6, baseY - house.height + 2);
                                ctx.lineTo(house.x + house.width + 6, baseY - house.height + 2);
                                ctx.lineTo(house.x + house.width / 2, baseY - house.height - house.roofHeight);
                            }
                            ctx.closePath();
                            ctx.fill();

                            // 立柱和门廊（别墅细节）
                            ctx.fillStyle = '#d9cfbd';
                            ctx.fillRect(house.x + 8, baseY - 18, 6, 18);
                            ctx.fillRect(house.x + house.width - 14, baseY - 18, 6, 18);
                            ctx.fillRect(house.x + 6, baseY - 20, house.width - 12, 4);

                            // 门窗细节
                            ctx.fillStyle = '#6a4f3a';
                            ctx.fillRect(house.x + house.width * 0.45, baseY - 24, 12, 24);
                            ctx.fillStyle = '#98c8e5';
                            ctx.fillRect(house.x + 12, baseY - house.height + 16, 14, 10);
                            ctx.fillRect(house.x + house.width - 26, baseY - house.height + 16, 14, 10);
                            ctx.fillRect(house.x + house.width * 0.35, baseY - house.height + 36, 12, 9);
                            ctx.fillRect(house.x + house.width * 0.62, baseY - house.height + 36, 12, 9);

                            // 房屋阴影，增强落地感
                            ctx.fillStyle = 'rgba(0, 0, 0, 0.12)';
                            ctx.beginPath();
                            ctx.ellipse(
                                house.x + house.width * 0.52,
                                groundTop + 6,
                                house.width * 0.62,
                                9,
                                0,
                                0,
                                Math.PI * 2
                            );
                            ctx.fill();
                        }
                    }

                    if (layer.trees) {
                        for (const tree of layer.trees) {
                            const baseY = groundTop + 5 - tree.yOffset;
                            // 树干
                            ctx.fillStyle = '#7b5432';
                            ctx.fillRect(tree.x, baseY - tree.trunk, 6, tree.trunk);

                            // 树冠
                            ctx.fillStyle = '#5a9b4d';
                            ctx.beginPath();
                            ctx.arc(tree.x + 2, baseY - tree.trunk - tree.size * 0.35, tree.size * 0.55, 0, Math.PI * 2);
                            ctx.arc(tree.x - tree.size * 0.35, baseY - tree.trunk - tree.size * 0.1, tree.size * 0.42, 0, Math.PI * 2);
                            ctx.arc(tree.x + tree.size * 0.4, baseY - tree.trunk - tree.size * 0.12, tree.size * 0.45, 0, Math.PI * 2);
                            ctx.fill();

                            // 阴影增强落地感
                            ctx.fillStyle = 'rgba(0, 0, 0, 0.1)';
                            ctx.beginPath();
                            ctx.ellipse(tree.x + 3, groundTop + 6, tree.size * 0.65, 5, 0, 0, Math.PI * 2);
                            ctx.fill();
                        }
                    }
                    
                    if (layer.clouds) {
                        ctx.fillStyle = layer.color;
                        for (const cloud of layer.clouds) {
                            ctx.beginPath();
                            ctx.arc(cloud.x, cloud.y, cloud.size, 0, Math.PI * 2);
                            ctx.arc(cloud.x + cloud.size * 0.5, cloud.y - cloud.size * 0.3, cloud.size * 0.7, 0, Math.PI * 2);
                            ctx.arc(cloud.x + cloud.size, cloud.y, cloud.size * 0.8, 0, Math.PI * 2);
                            ctx.fill();
                        }
                    }
                }

                // 地平线草地
                const grass = ctx.createLinearGradient(0, groundTop, 0, height);
                grass.addColorStop(0, '#628e54');
                grass.addColorStop(1, '#3f6f3a');
                ctx.fillStyle = grass;
                ctx.fillRect(0, groundTop, width, height - groundTop);

                // 小桥（跨河简化造型）
                ctx.fillStyle = '#8c7a66';
                ctx.fillRect(width * 0.64, groundTop - 12, 70, 6);
                ctx.fillRect(width * 0.64 + 8, groundTop - 6, 5, 10);
                ctx.fillRect(width * 0.64 + 57, groundTop - 6, 5, 10);

                // 草地纹理
                ctx.strokeStyle = 'rgba(30, 72, 34, 0.24)';
                ctx.lineWidth = 1;
                for (let x = 0; x < width; x += 18) {
                    ctx.beginPath();
                    ctx.moveTo(x, groundTop + 4 + Math.sin(x * 0.03) * 1.5);
                    ctx.lineTo(x + 2, groundTop + 13 + Math.sin(x * 0.03) * 1.5);
                    ctx.stroke();
                }
            }
        }

        /**
         * 碰撞检测系统
         * Collision Detection System
         */
        class CollisionSystem {
            static checkAABB(a, b) {
                return a.x < b.x + b.width &&
                       a.x + a.width > b.x &&
                       a.y < b.y + b.height &&
                       a.y + a.height > b.y;
            }

            static checkCircleCollision(pos1, radius1, pos2, radius2) {
                const dx = pos1.x - pos2.x;
                const dy = pos1.y - pos2.y;
                const distance = Math.sqrt(dx * dx + dy * dy);
                return distance < radius1 + radius2;
            }

            static checkBulletEnemyCollisions(bullets, enemies) {
                for (const bullet of bullets) {
                    if (!bullet.active || bullet.owner !== 'player') continue;
                    
                    for (const enemy of enemies) {
                        if (!enemy.active) continue;
                        
                        if (this.checkCircleCollision(
                            bullet.position, bullet.size,
                            enemy.position, enemy.size / 2
                        )) {
                            enemy.takeDamage(bullet.damage);
                            if (bullet.type === 'missile') {
                                // 导弹命中：冲击火球 + 金属火花 + 轻微范围伤害
                                game.particles.emitExplosion(bullet.position.x, bullet.position.y, 1.2);
                                game.particles.emit(bullet.position.x, bullet.position.y, 18, {
                                    speed: 5,
                                    life: 22,
                                    size: 2.2,
                                    color: '#b7c8d5',
                                    type: 'spark'
                                });
                                game.particles.emit(bullet.position.x, bullet.position.y, 14, {
                                    speed: 3.2,
                                    life: 28,
                                    size: 3.5,
                                    color: '#6c6f73',
                                    type: 'smoke'
                                });
                                game.screenShake = Math.max(game.screenShake, 8);

                                for (const splash of enemies) {
                                    if (!splash.active || splash === enemy) continue;
                                    const splashDist = bullet.position.distance(splash.position);
                                    if (splashDist < 65) {
                                        splash.takeDamage(Math.max(8, bullet.damage * 0.35));
                                    }
                                }
                            } else {
                                game.particles.emit(bullet.position.x, bullet.position.y, 6, {
                                    speed: 3,
                                    life: 14,
                                    size: 2,
                                    color: '#ffd1a8',
                                    type: 'spark'
                                });
                            }
                            bullet.active = false;
                            break;
                        }
                    }
                }
            }

            static checkBulletPlayerCollisions(bullets, helicopter) {
                for (const bullet of bullets) {
                    if (!bullet.active || (bullet.owner !== 'enemy' && bullet.owner !== 'ground')) continue;
                    
                    // 检查护盾
                    if (helicopter.shieldActive) {
                        if (this.checkCircleCollision(
                            bullet.position, bullet.size,
                            helicopter.position, helicopter.shieldRadius
                        )) {
                            bullet.active = false;
                            game.particles.emit(bullet.position.x, bullet.position.y, 5, {
                                color: '#44ffff',
                                type: 'spark'
                            });
                            continue;
                        }
                    }
                    
                    // 检查机体
                    const bounds = helicopter.getBounds();
                    if (this.checkCircleCollision(
                        bullet.position, bullet.size,
                        new Vector2(bounds.x + bounds.width / 2, bounds.y + bounds.height / 2),
                        Math.min(bounds.width, bounds.height) / 2
                    )) {
                        helicopter.takeDamage(bullet.damage);
                        bullet.active = false;
                    }
                }
            }

            static checkBulletGroundEnemyCollisions(bullets, groundEnemies) {
                for (const bullet of bullets) {
                    if (!bullet.active || bullet.owner !== 'player') continue;

                    for (const enemy of groundEnemies) {
                        if (!enemy.active) continue;
                        const bounds = enemy.getBounds();
                        if (this.checkAABB(
                            {
                                x: bullet.position.x - bullet.size,
                                y: bullet.position.y - bullet.size,
                                width: bullet.size * 2,
                                height: bullet.size * 2
                            },
                            bounds
                        )) {
                            enemy.takeDamage(bullet.damage);
                            bullet.active = false;
                            break;
                        }
                    }
                }
            }

            static checkEnemyPlayerCollisions(enemies, helicopter) {
                for (const enemy of enemies) {
                    if (!enemy.active) continue;
                    
                    const enemyBounds = enemy.getBounds();
                    const heliBounds = helicopter.getBounds();
                    
                    if (this.checkAABB(enemyBounds, heliBounds)) {
                        helicopter.takeDamage(enemy.damage);
                        enemy.takeDamage(50);  // 撞击伤害
                    }
                }
            }
        }

        /**
         * 主游戏类
         * Main Game Class
         */
        class Game {
            constructor() {
                this.canvas = document.getElementById('gameCanvas');
                this.ctx = this.canvas.getContext('2d');
                
                this.resizeCanvas();
                window.addEventListener('resize', () => this.resizeCanvas());
                
                this.input = new InputManager();
                this.audio = new AudioManager();
                this.particles = new ParticleSystem();
                this.bullets = new BulletManager();
                this.background = new Background();
                this.powerUpManager = new PowerUpManager();
                this.groundEnemyManager = new GroundEnemyManager();
                
                this.helicopter = null;
                this.enemies = [];
                this.enemyManager = null;
                
                this.score = 0;
                this.combo = 0;
                this.comboTimer = 0;
                this.scoreMultiplier = 1;
                
                this.screenShake = 0;
                this.gameState = 'start';  // start, playing, paused, gameover, victory
                this.missileLocked = false;
                
                this.lastTime = 0;
                this.deltaTime = 0;
                
                this.setupEventListeners();
            }

            resizeCanvas() {
                const container = document.getElementById('gameContainer');
                this.canvas.width = container.clientWidth;
                this.canvas.height = container.clientHeight;
            }

            setupEventListeners() {
                document.getElementById('startBtn').addEventListener('click', () => this.start());
                document.getElementById('resumeBtn').addEventListener('click', () => this.resume());
                document.getElementById('restartBtn').addEventListener('click', () => this.restart());
                document.getElementById('victoryRestartBtn').addEventListener('click', () => this.restart());
            }

            start() {
                this.audio.init();
                document.getElementById('startScreen').classList.add('hidden');
                this.initGame();
                this.gameState = 'playing';
                this.lastTime = performance.now();
                this.gameLoop(this.lastTime);
            }

            initGame() {
                this.helicopter = new Helicopter(150, this.canvas.height / 2);
                this.enemyManager = new EnemyManager();
                this.enemies = this.enemyManager.enemies;
                
                this.score = 0;
                this.combo = 0;
                this.comboTimer = 0;
                this.scoreMultiplier = 1;
                this.screenShake = 0;
                this.missileLocked = false;
                
                this.bullets.clear();
                this.particles.clear();
                this.powerUpManager.clear();
                this.groundEnemyManager.clear();
                
                this.updateHUD();
            }

            restart() {
                document.getElementById('gameOverScreen').classList.add('hidden');
                document.getElementById('victoryScreen').classList.add('hidden');
                this.initGame();
                this.gameState = 'playing';
                this.lastTime = performance.now();
                this.gameLoop(this.lastTime);
            }

            togglePause() {
                if (this.gameState === 'playing') {
                    this.gameState = 'paused';
                    document.getElementById('pauseScreen').classList.remove('hidden');
                } else if (this.gameState === 'paused') {
                    this.resume();
                }
            }

            resume() {
                this.gameState = 'playing';
                document.getElementById('pauseScreen').classList.add('hidden');
                this.lastTime = performance.now();
            }

            gameOver() {
                this.gameState = 'gameover';
                document.getElementById('finalScore').textContent = this.score;
                document.getElementById('gameOverScreen').classList.remove('hidden');
            }

            victory() {
                this.gameState = 'victory';
                document.getElementById('victoryScore').textContent = this.score;
                document.getElementById('victoryScreen').classList.remove('hidden');
            }

            addScore(points) {
                this.score += Math.floor(points * this.scoreMultiplier);
                this.updateHUD();
            }

            addCombo() {
                this.combo++;
                this.comboTimer = 120;  // 2秒
                this.scoreMultiplier = 1 + Math.floor(this.combo / 5) * 0.5;
                
                // 显示连击
                const comboDisplay = document.getElementById('comboDisplay');
                comboDisplay.textContent = `COMBO x${this.combo}`;
                comboDisplay.classList.add('show');
            }

            spawnPowerUp(x, y) {
                this.powerUpManager.spawn(x, y);
            }

            bossDefeated() {
                this.enemyManager.bossDefeated();
            }

            updateHUD() {
                // 血条
                const healthPercent = (this.helicopter.health / this.helicopter.maxHealth) * 100;
                document.getElementById('healthBar').style.width = healthPercent + '%';
                
                // 护盾条
                const shieldPercent = (this.helicopter.shield / this.helicopter.maxShield) * 100;
                document.getElementById('shieldBar').style.width = shieldPercent + '%';
                
                // 能量条
                const energyPercent = (this.helicopter.energy / this.helicopter.maxEnergy) * 100;
                document.getElementById('energyBar').style.width = energyPercent + '%';
                
                // 分数
                document.getElementById('scoreDisplay').textContent = this.score;
                
                // 武器冷却
                for (let i = 0; i < 4; i++) {
                    const cooldown = this.helicopter.weaponCooldowns[i];
                    const maxCooldown = CONFIG.WEAPON_COOLDOWNS[i];
                    const percent = Math.max(0, 1 - cooldown / maxCooldown) * 100;
                    document.getElementById(`cooldown${i}`).style.width = percent + '%';
                }

                const lockStatusEl = document.getElementById('missileLockStatus');
                if (lockStatusEl) {
                    lockStatusEl.textContent = this.missileLocked ? 'MISSILE: LOCK' : 'MISSILE: SCAN';
                    lockStatusEl.classList.toggle('locked', this.missileLocked);
                }
            }

            gameLoop(currentTime = 0) {
                if (this.gameState !== 'playing') {
                    if (this.gameState === 'paused') {
                        requestAnimationFrame((t) => this.gameLoop(t));
                    }
                    return;
                }
                
                // 计算 Delta Time
                this.deltaTime = (currentTime - this.lastTime) / 16.67;  // 标准化为 60FPS
                // 限制步长并阻止负值，避免首帧或时钟回拨导致的异常更新
                this.deltaTime = Math.max(0, Math.min(this.deltaTime, CONFIG.DELTA_TIME_MAX));
                this.lastTime = currentTime;
                
                // 更新
                this.update(this.deltaTime);
                
                // 渲染
                this.render();
                
                // 下一帧
                requestAnimationFrame((t) => this.gameLoop(t));
            }

            update(dt) {
                // 更新背景
                this.background.update(dt);
                
                // 更新直升机
                this.helicopter.update(dt);
                
                // 更新敌人
                this.enemyManager.update(dt);
                
                // 更新子弹
                this.bullets.update(dt);
                
                // 更新粒子
                this.particles.update(dt);
                
                // 更新道具
                this.powerUpManager.update(dt);
                this.groundEnemyManager.update(dt);
                
                // 道具碰撞检测
                this.powerUpManager.checkCollision(this.helicopter);
                
                // 碰撞检测
                CollisionSystem.checkBulletEnemyCollisions(this.bullets.bullets, this.enemies);
                CollisionSystem.checkBulletPlayerCollisions(this.bullets.bullets, this.helicopter);
                CollisionSystem.checkBulletGroundEnemyCollisions(this.bullets.bullets, this.groundEnemyManager.enemies);
                CollisionSystem.checkEnemyPlayerCollisions(this.enemies, this.helicopter);

                const wasLocked = this.missileLocked;
                this.missileLocked = this.bullets.bullets.some(
                    b => b.active && b.owner === 'player' && b.type === 'missile' && b.missileLocked
                );
                if (!wasLocked && this.missileLocked) {
                    this.audio.playSound('lock');
                }
                
                // 连击计时器
                if (this.combo > 0) {
                    this.comboTimer -= dt;
                    if (this.comboTimer <= 0) {
                        this.combo = 0;
                        this.scoreMultiplier = 1;
                        document.getElementById('comboDisplay').classList.remove('show');
                    }
                }
                
                // 屏幕震动衰减
                if (this.screenShake > 0) {
                    this.screenShake *= 0.9;
                    if (this.screenShake < 0.5) this.screenShake = 0;
                }
                
                // 更新 HUD
                this.updateHUD();
            }

            render() {
                const ctx = this.ctx;
                
                // 清空画布
                ctx.fillStyle = '#7f94aa';
                ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
                
                // 应用屏幕震动
                ctx.save();
                if (this.screenShake > 0) {
                    ctx.translate(
                        (Math.random() - 0.5) * this.screenShake,
                        (Math.random() - 0.5) * this.screenShake
                    );
                }
                
                // 渲染背景
                this.background.render(ctx);
                
                // 渲染道具
                this.powerUpManager.render(ctx);
                
                // 渲染子弹
                this.bullets.render(ctx);
                
                // 渲染敌人
                this.enemyManager.render(ctx);
                this.groundEnemyManager.render(ctx);
                
                // 渲染直升机
                this.helicopter.render(ctx);
                
                // 渲染粒子
                this.particles.render(ctx);
                
                ctx.restore();
            }
        }

        // 初始化游戏
        const game = new Game();
    </script>
</body>
</html>
```
