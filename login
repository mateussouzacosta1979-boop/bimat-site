<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CRM Advocacia - Sistema Profissional</title>
    <script>
// Storage adapter para usar localStorage
const storage = {
    get: (key) => {
        try {
            const value = localStorage.getItem(key);
            if (!value) return null;
            return { value: value, key: key };
        } catch (error) {
            console.error('Erro ao ler storage:', error);
            throw error;
        }
    },
    set: (key, value) => {
        try {
            localStorage.setItem(key, value);
            return { value: value, key: key };
        } catch (error) {
            console.error('Erro ao salvar storage:', error);
            throw error;
        }
    },
    delete: (key) => {
        try {
            localStorage.removeItem(key);
            return { key: key, deleted: true };
        } catch (error) {
            console.error('Erro ao deletar storage:', error);
            throw error;
        }
    }
};
window.storage = storage;

// Inicializar usuário admin
const initAdmin = () => {
    let users = storage.get('users_list');
    if (!users || !users.value) {
        const adminUser = {
            id: 'admin-001',
            nome: 'Administrador',
            usuario: 'admin',
            senha: 'admin',
            perfil: 'admin',
            ativo: true,
            permissoes: { clientes: 'editar', demandas: 'editar', usuarios: 'editar', relatorios: 'editar' },
            criadoEm: new Date().toISOString()
        };
        storage.set('users_list', JSON.stringify([adminUser]));
    }
};
initAdmin();
    </script>
    <script crossorigin src="https://unpkg.com/react@18/umd/react.production.min.js"></script>
    <script crossorigin src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"></script>
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Inter', sans-serif; 
            background: #f8fafc;
            color: #1e293b;
        }
        .sidebar {
            background: #ffffff;
            border-right: 1px solid #e2e8f0;
            min-height: 100vh;
            width: 260px;
            position: fixed;
            left: 0;
            top: 0;
            box-shadow: 2px 0 8px rgba(0,0,0,0.02);
        }
        .sidebar-item {
            padding: 12px 20px;
            margin: 2px 12px;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 12px;
            color: #64748b;
            font-weight: 500;
            font-size: 14px;
        }
        .sidebar-item:hover { background: #f1f5f9; color: #3b82f6; }
        .sidebar-item.active { 
            background: #3b82f6; 
            color: white;
            box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
        }
        .btn-primary {
            background: #3b82f6;
            color: white;
            padding: 10px 20px;
            border-radius: 8px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            font-size: 14px;
        }
        .btn-primary:hover { background: #2563eb; transform: translateY(-1px); }
        .btn-secondary {
            background: #f1f5f9;
            color: #475569;
            padding: 10px 20px;
            border-radius: 8px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            font-size: 14px;
        }
        .btn-secondary:hover { background: #e2e8f0; }
        .btn-success {
            background: #10b981;
            color: white;
            padding: 10px 20px;
            border-radius: 8px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            font-size: 14px;
        }
        .btn-success:hover { background: #059669; }
        .btn-danger {
            background: #ef4444;
            color: white;
            padding: 8px 16px;
            border-radius: 6px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            font-size: 13px;
        }
        .btn-danger:hover { background: #dc2626; }
        .input-field, select, textarea {
            width: 100%;
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 10px 14px;
            color: #1e293b;
            font-size: 14px;
            transition: all 0.2s;
            font-family: 'Inter', sans-serif;
        }
        .input-field:focus, select:focus, textarea:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }
        .card {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        .modal-overlay {
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1000;
        }
        .modal-content {
            background: white;
            border-radius: 16px;
            max-width: 900px;
            width: 90%;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        table { width: 100%; border-collapse: collapse; }
        thead { background: #f8fafc; }
        th {
            padding: 12px 16px;
            text-align: left;
            font-weight: 600;
            color: #64748b;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid #e2e8f0;
        }
        td {
            padding: 14px 16px;
            border-bottom: 1px solid #f1f5f9;
            color: #475569;
            font-size: 14px;
        }
        tr:hover td { background: #f8fafc; }
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        .status-ativo { background: #dcfce7; color: #16a34a; }
        .status-pendente { background: #fef3c7; color: #ca8a04; }
        .status-concluido { background: #dbeafe; color: #2563eb; }
        .status-cancelado { background: #fee2e2; color: #dc2626; }
        .status-atrasado { background: #fce7f3; color: #db2777; }
        
        .calendar-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: 1px;
            background: #e2e8f0;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            overflow: hidden;
        }
        .calendar-day-header {
            background: #f1f5f9;
            padding: 12px;
            text-align: center;
            font-weight: 600;
            font-size: 12px;
            color: #64748b;
            text-transform: uppercase;
        }
        .calendar-day {
            background: white;
            min-height: 100px;
            padding: 8px;
            cursor: pointer;
            transition: all 0.2s;
            position: relative;
        }
        .calendar-day:hover { background: #f8fafc; }
        .calendar-day.other-month { background: #f8fafc; opacity: 0.5; }
        .calendar-day.today { 
            background: #eff6ff;
            border: 2px solid #3b82f6;
        }
        .calendar-day-number {
            font-weight: 600;
            font-size: 14px;
            color: #475569;
            margin-bottom: 4px;
        }
        .calendar-event {
            background: #3b82f6;
            color: white;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 11px;
            margin-bottom: 2px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            cursor: pointer;
        }
        .calendar-event:hover { background: #2563eb; }
        .calendar-event.atrasado { background: #ef4444; }
        
        .workflow-step {
            background: white;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            padding: 16px;
            margin-bottom: 12px;
            transition: all 0.2s;
        }
        .workflow-step:hover { border-color: #3b82f6; box-shadow: 0 4px 12px rgba(59, 130, 246, 0.1); }
        .workflow-step.concluida { 
            background: #f0fdf4; 
            border-color: #10b981;
        }
        .workflow-step.atrasada { 
            background: #fef2f2; 
            border-color: #ef4444;
        }
        
        ::-webkit-scrollbar { width: 8px; height: 8px; }
        ::-webkit-scrollbar-track { background: #f1f5f9; }
        ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
    </style>
</head>
<body>
    <div id="root"></div>
    <script type="text/babel">
        const { useState, useEffect } = React;

        function App() {
            const [currentUser, setCurrentUser] = useState(null);
            const [currentPage, setCurrentPage] = useState('dashboard');

            useEffect(() => {
                const user = storage.get('current_user');
                if (user && user.value) setCurrentUser(JSON.parse(user.value));
            }, []);

            if (!currentUser) return <LoginPage onLogin={(u) => setCurrentUser(u)} />;

            return (
                <div style={{ display: 'flex' }}>
                    <Sidebar currentPage={currentPage} setCurrentPage={setCurrentPage} currentUser={currentUser} onLogout={() => { storage.delete('current_user'); setCurrentUser(null); }} />
                    <MainContent currentPage={currentPage} currentUser={currentUser} />
                </div>
            );
        }

        function LoginPage({ onLogin }) {
            const [username, setUsername] = useState('');
            const [password, setPassword] = useState('');
            const [error, setError] = useState('');

            const handleLogin = (e) => {
                e.preventDefault();
                const users = JSON.parse(storage.get('users_list')?.value || '[]');
                const user = users.find(u => u.usuario === username && u.senha === password);
                if (!user) { setError('Usuário ou senha incorretos'); return; }
                if (!user.ativo) { setError('Usuário inativo'); return; }
                storage.set('current_user', JSON.stringify(user));
                onLogin(user);
            };

            return (
                <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' }}>
                    <div style={{ background: 'white', padding: '48px', borderRadius: '16px', maxWidth: '420px', width: '90%', boxShadow: '0 20px 60px rgba(0,0,0,0.3)' }}>
                        <div style={{ textAlign: 'center', marginBottom: '32px' }}>
                            <div style={{ width: '60px', height: '60px', background: '#3b82f6', borderRadius: '12px', margin: '0 auto 16px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '28px' }}>⚖️</div>
                            <h1 style={{ fontSize: '24px', fontWeight: '800', marginBottom: '8px', color: '#1e293b' }}>CRM Advocacia</h1>
                            <p style={{ color: '#64748b', fontSize: '14px' }}>Sistema Profissional de Gestão</p>
                        </div>
                        <form onSubmit={handleLogin}>
                            <div style={{ marginBottom: '16px' }}>
                                <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '14px' }}>Usuário</label>
                                <input type="text" className="input-field" value={username} onChange={(e) => setUsername(e.target.value)} required />
                            </div>
                            <div style={{ marginBottom: '20px' }}>
                                <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '14px' }}>Senha</label>
                                <input type="password" className="input-field" value={password} onChange={(e) => setPassword(e.target.value)} required />
                            </div>
                            {error && <div style={{ background: '#fee2e2', color: '#dc2626', padding: '12px', borderRadius: '8px', marginBottom: '16px', fontSize: '13px' }}>{error}</div>}
                            <button type="submit" className="btn-primary" style={{ width: '100%' }}>Entrar</button>
                        </form>
                        <div style={{ marginTop: '24px', padding: '12px', background: '#f1f5f9', borderRadius: '8px', textAlign: 'center' }}>
                            <p style={{ fontSize: '12px', color: '#64748b' }}>Usuário e senha padrão: <strong>admin</strong></p>
                        </div>
                    </div>
                </div>
            );
        }

        function Sidebar({ currentPage, setCurrentPage, currentUser, onLogout }) {
            const items = [
                { id: 'dashboard', label: 'Dashboard', icon: '📊' },
                { id: 'agenda', label: 'Agenda', icon: '📅' },
                { id: 'clientes', label: 'Clientes', icon: '👥', perm: 'clientes' },
                { id: 'demandas', label: 'Demandas', icon: '📋', perm: 'demandas' },
                { id: 'usuarios', label: 'Usuários', icon: '👤', perm: 'usuarios' },
                { id: 'perfil', label: 'Meu Perfil', icon: '⚙️' },
            ];

            return (
                <div className="sidebar">
                    <div style={{ padding: '24px 20px', borderBottom: '1px solid #e2e8f0' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                            <div style={{ width: '40px', height: '40px', background: '#3b82f6', borderRadius: '10px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '20px' }}>⚖️</div>
                            <div>
                                <h2 style={{ fontSize: '16px', fontWeight: '700', color: '#1e293b' }}>CRM Advocacia</h2>
                                <p style={{ fontSize: '11px', color: '#94a3b8' }}>Sistema Profissional</p>
                            </div>
                        </div>
                    </div>
                    <div style={{ padding: '16px 0' }}>
                        {items.filter(i => !i.perm || currentUser.perfil === 'admin' || currentUser.permissoes[i.perm] !== 'nenhum').map(item => (
                            <div key={item.id} className={`sidebar-item ${currentPage === item.id ? 'active' : ''}`} onClick={() => setCurrentPage(item.id)}>
                                <span style={{ fontSize: '18px' }}>{item.icon}</span>
                                <span>{item.label}</span>
                            </div>
                        ))}
                    </div>
                    <div style={{ position: 'absolute', bottom: '0', left: '0', right: '0', padding: '20px', borderTop: '1px solid #e2e8f0' }}>
                        <div style={{ marginBottom: '12px', padding: '12px', background: '#f8fafc', borderRadius: '8px' }}>
                            <p style={{ fontSize: '13px', fontWeight: '600', color: '#1e293b' }}>{currentUser.nome}</p>
                            <p style={{ fontSize: '12px', color: '#64748b' }}>@{currentUser.usuario}</p>
                        </div>
                        <button onClick={onLogout} className="btn-secondary" style={{ width: '100%', fontSize: '13px' }}>🚪 Sair</button>
                    </div>
                </div>
            );
        }

        function MainContent({ currentPage, currentUser }) {
            return (
                <div style={{ marginLeft: '260px', padding: '32px', width: 'calc(100% - 260px)', minHeight: '100vh', background: '#f8fafc' }}>
                    {currentPage === 'dashboard' && <Dashboard />}
                    {currentPage === 'agenda' && <Agenda />}
                    {currentPage === 'clientes' && <Clientes currentUser={currentUser} />}
                    {currentPage === 'demandas' && <Demandas currentUser={currentUser} />}
                    {currentPage === 'usuarios' && <Usuarios currentUser={currentUser} />}
                    {currentPage === 'perfil' && <Perfil currentUser={currentUser} />}
                </div>
            );
        }

        // DASHBOARD
        function Dashboard() {
            const [metrics, setMetrics] = useState({ clientes: 0, ativas: 0, concluidas: 0, pendentes: 0, atrasadas: 0 });

            useEffect(() => {
                const clientes = JSON.parse(storage.get('clientes_list')?.value || '[]');
                const demandas = JSON.parse(storage.get('demandas_list')?.value || '[]');
                
                let atrasadas = 0;
                demandas.forEach(d => {
                    if (d.etapas) {
                        d.etapas.forEach(e => {
                            if (!e.concluida && e.prazo && new Date(e.prazo) < new Date()) atrasadas++;
                        });
                    }
                });

                setMetrics({
                    clientes: clientes.length,
                    ativas: demandas.filter(d => d.status === 'ativo').length,
                    concluidas: demandas.filter(d => d.status === 'concluido').length,
                    pendentes: demandas.filter(d => d.status === 'pendente').length,
                    atrasadas
                });
            }, []);

            return (
                <div>
                    <div style={{ marginBottom: '32px' }}>
                        <h1 style={{ fontSize: '28px', fontWeight: '800', marginBottom: '8px', color: '#1e293b' }}>Dashboard</h1>
                        <p style={{ color: '#64748b', fontSize: '14px' }}>Visão geral do sistema</p>
                    </div>
                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '20px' }}>
                        {[
                            { label: 'Clientes', value: metrics.clientes, icon: '👥', color: '#3b82f6' },
                            { label: 'Demandas Ativas', value: metrics.ativas, icon: '📋', color: '#10b981' },
                            { label: 'Pendentes', value: metrics.pendentes, icon: '⏳', color: '#f59e0b' },
                            { label: 'Concluídas', value: metrics.concluidas, icon: '✅', color: '#6366f1' },
                            { label: 'Prazos Atrasados', value: metrics.atrasadas, icon: '⚠️', color: '#ef4444' },
                        ].map((m, i) => (
                            <div key={i} className="card" style={{ textAlign: 'center', borderLeft: `4px solid ${m.color}` }}>
                                <div style={{ fontSize: '32px', marginBottom: '12px' }}>{m.icon}</div>
                                <div style={{ fontSize: '32px', fontWeight: '800', color: m.color, marginBottom: '4px' }}>{m.value}</div>
                                <div style={{ fontSize: '13px', fontWeight: '600', color: '#64748b' }}>{m.label}</div>
                            </div>
                        ))}
                    </div>
                </div>
            );
        }

        // AGENDA/CALENDÁRIO
        function Agenda() {
            const [currentMonth, setCurrentMonth] = useState(new Date());
            const [events, setEvents] = useState([]);
            const [selectedEvent, setSelectedEvent] = useState(null);

            useEffect(() => {
                loadEvents();
            }, []);

            const loadEvents = () => {
                const demandas = JSON.parse(storage.get('demandas_list')?.value || '[]');
                const clientes = JSON.parse(storage.get('clientes_list')?.value || '[]');
                const allEvents = [];

                demandas.forEach(d => {
                    const cliente = clientes.find(c => c.id === d.clienteId);
                    if (d.etapas) {
                        d.etapas.forEach(e => {
                            if (e.prazo) {
                                allEvents.push({
                                    id: `${d.id}-${e.id}`,
                                    demandaId: d.id,
                                    etapaId: e.id,
                                    titulo: e.titulo,
                                    demandaTitulo: d.titulo,
                                    cliente: cliente?.nome || 'Cliente não encontrado',
                                    prazo: new Date(e.prazo),
                                    concluida: e.concluida,
                                    descricao: e.descricao
                                });
                            }
                        });
                    }
                });

                setEvents(allEvents);
            };

            const getDaysInMonth = () => {
                const year = currentMonth.getFullYear();
                const month = currentMonth.getMonth();
                const firstDay = new Date(year, month, 1);
                const lastDay = new Date(year, month + 1, 0);
                const daysInMonth = lastDay.getDate();
                const startDayOfWeek = firstDay.getDay();

                const days = [];
                // Dias do mês anterior
                const prevMonthLastDay = new Date(year, month, 0).getDate();
                for (let i = startDayOfWeek - 1; i >= 0; i--) {
                    days.push({ date: new Date(year, month - 1, prevMonthLastDay - i), isOtherMonth: true });
                }
                // Dias do mês atual
                for (let i = 1; i <= daysInMonth; i++) {
                    days.push({ date: new Date(year, month, i), isOtherMonth: false });
                }
                // Dias do próximo mês
                const remainingDays = 42 - days.length; // 6 semanas
                for (let i = 1; i <= remainingDays; i++) {
                    days.push({ date: new Date(year, month + 1, i), isOtherMonth: true });
                }

                return days;
            };

            const getEventsForDay = (date) => {
                return events.filter(e => 
                    e.prazo.getDate() === date.getDate() &&
                    e.prazo.getMonth() === date.getMonth() &&
                    e.prazo.getFullYear() === date.getFullYear()
                );
            };

            const isToday = (date) => {
                const today = new Date();
                return date.getDate() === today.getDate() &&
                       date.getMonth() === today.getMonth() &&
                       date.getFullYear() === today.getFullYear();
            };

            const isOverdue = (event) => {
                return !event.concluida && event.prazo < new Date();
            };

            const monthNames = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
            const dayNames = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

            return (
                <div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
                        <div>
                            <h1 style={{ fontSize: '28px', fontWeight: '800', color: '#1e293b' }}>Agenda</h1>
                            <p style={{ color: '#64748b', fontSize: '14px' }}>Visualize todos os seus prazos</p>
                        </div>
                        <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
                            <button className="btn-secondary" onClick={() => setCurrentMonth(new Date(currentMonth.setMonth(currentMonth.getMonth() - 1)))}>← Anterior</button>
                            <button className="btn-secondary" onClick={() => setCurrentMonth(new Date())}>Hoje</button>
                            <button className="btn-secondary" onClick={() => setCurrentMonth(new Date(currentMonth.setMonth(currentMonth.getMonth() + 1)))}>Próximo →</button>
                        </div>
                    </div>

                    <div className="card">
                        <h2 style={{ fontSize: '20px', fontWeight: '700', marginBottom: '20px', color: '#1e293b' }}>
                            {monthNames[currentMonth.getMonth()]} {currentMonth.getFullYear()}
                        </h2>
                        
                        <div className="calendar-grid">
                            {dayNames.map(day => (
                                <div key={day} className="calendar-day-header">{day}</div>
                            ))}
                            {getDaysInMonth().map((day, idx) => {
                                const dayEvents = getEventsForDay(day.date);
                                return (
                                    <div key={idx} className={`calendar-day ${day.isOtherMonth ? 'other-month' : ''} ${isToday(day.date) ? 'today' : ''}`}>
                                        <div className="calendar-day-number">{day.date.getDate()}</div>
                                        {dayEvents.slice(0, 3).map(event => (
                                            <div 
                                                key={event.id} 
                                                className={`calendar-event ${isOverdue(event) ? 'atrasado' : ''}`}
                                                onClick={() => setSelectedEvent(event)}
                                                title={event.titulo}
                                            >
                                                {event.concluida ? '✓ ' : ''}{event.titulo}
                                            </div>
                                        ))}
                                        {dayEvents.length > 3 && (
                                            <div style={{ fontSize: '10px', color: '#64748b', marginTop: '2px' }}>+{dayEvents.length - 3} mais</div>
                                        )}
                                    </div>
                                );
                            })}
                        </div>
                    </div>

                    {selectedEvent && (
                        <div className="modal-overlay" onClick={() => setSelectedEvent(null)}>
                            <div className="modal-content" onClick={(e) => e.stopPropagation()} style={{ maxWidth: '600px' }}>
                                <div style={{ padding: '24px', borderBottom: '1px solid #e2e8f0' }}>
                                    <h2 style={{ fontSize: '22px', fontWeight: '800', color: '#1e293b' }}>{selectedEvent.titulo}</h2>
                                    <p style={{ color: '#64748b', fontSize: '14px', marginTop: '4px' }}>{selectedEvent.demandaTitulo}</p>
                                </div>
                                <div style={{ padding: '24px' }}>
                                    <div style={{ marginBottom: '16px' }}>
                                        <p style={{ fontSize: '13px', fontWeight: '600', color: '#64748b', marginBottom: '4px' }}>Cliente</p>
                                        <p style={{ fontSize: '15px', color: '#1e293b' }}>{selectedEvent.cliente}</p>
                                    </div>
                                    <div style={{ marginBottom: '16px' }}>
                                        <p style={{ fontSize: '13px', fontWeight: '600', color: '#64748b', marginBottom: '4px' }}>Prazo</p>
                                        <p style={{ fontSize: '15px', color: '#1e293b' }}>{selectedEvent.prazo.toLocaleDateString('pt-BR')} às {selectedEvent.prazo.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}</p>
                                    </div>
                                    {selectedEvent.descricao && (
                                        <div style={{ marginBottom: '16px' }}>
                                            <p style={{ fontSize: '13px', fontWeight: '600', color: '#64748b', marginBottom: '4px' }}>Descrição</p>
                                            <p style={{ fontSize: '14px', color: '#475569', lineHeight: '1.6' }}>{selectedEvent.descricao}</p>
                                        </div>
                                    )}
                                    <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                                        <span className={`status-badge ${selectedEvent.concluida ? 'status-concluido' : isOverdue(selectedEvent) ? 'status-atrasado' : 'status-pendente'}`}>
                                            {selectedEvent.concluida ? 'Concluída' : isOverdue(selectedEvent) ? 'Atrasada' : 'Pendente'}
                                        </span>
                                    </div>
                                    <div style={{ marginTop: '24px', display: 'flex', justifyContent: 'flex-end' }}>
                                        <button className="btn-secondary" onClick={() => setSelectedEvent(null)}>Fechar</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    )}
                </div>
            );
        }

        // CLIENTES (versão simplificada)
        function Clientes({ currentUser }) {
            const [clientes, setClientes] = useState([]);
            const [showModal, setShowModal] = useState(false);
            const [selected, setSelected] = useState(null);

            useEffect(() => {
                loadClientes();
            }, []);

            const loadClientes = () => {
                setClientes(JSON.parse(storage.get('clientes_list')?.value || '[]'));
            };

            const canEdit = currentUser.perfil === 'admin' || currentUser.permissoes.clientes === 'editar';

            const handleSave = (cliente) => {
                const list = JSON.parse(storage.get('clientes_list')?.value || '[]');
                if (selected) {
                    const idx = list.findIndex(c => c.id === cliente.id);
                    list[idx] = cliente;
                } else {
                    list.push({ ...cliente, id: Date.now().toString(), criadoEm: new Date().toISOString(), historico: [] });
                }
                storage.set('clientes_list', JSON.stringify(list));
                loadClientes();
                setShowModal(false);
                setSelected(null);
            };

            const handleDelete = (id) => {
                if (!confirm('Deseja excluir?')) return;
                const list = JSON.parse(storage.get('clientes_list')?.value || '[]').filter(c => c.id !== id);
                storage.set('clientes_list', JSON.stringify(list));
                loadClientes();
            };

            return (
                <div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
                        <div>
                            <h1 style={{ fontSize: '28px', fontWeight: '800', color: '#1e293b' }}>Clientes</h1>
                            <p style={{ color: '#64748b', fontSize: '14px' }}>Gerenciamento de clientes</p>
                        </div>
                        {canEdit && <button className="btn-primary" onClick={() => { setSelected(null); setShowModal(true); }}>➕ Novo Cliente</button>}
                    </div>

                    <div className="card">
                        <table>
                            <thead>
                                <tr>
                                    <th>Nome</th>
                                    <th>CPF/CNPJ</th>
                                    <th>Email</th>
                                    <th>Telefone</th>
                                    <th>Cadastrado</th>
                                    {canEdit && <th style={{ textAlign: 'right' }}>Ações</th>}
                                </tr>
                            </thead>
                            <tbody>
                                {clientes.length === 0 ? (
                                    <tr><td colSpan="6" style={{ textAlign: 'center', padding: '32px', color: '#94a3b8' }}>Nenhum cliente cadastrado</td></tr>
                                ) : (
                                    clientes.map(c => (
                                        <tr key={c.id}>
                                            <td style={{ fontWeight: '600' }}>{c.nome}</td>
                                            <td>{c.cpfCnpj}</td>
                                            <td>{c.email}</td>
                                            <td>{c.telefone}</td>
                                            <td>{new Date(c.criadoEm).toLocaleDateString('pt-BR')}</td>
                                            {canEdit && (
                                                <td style={{ textAlign: 'right' }}>
                                                    <button onClick={() => { setSelected(c); setShowModal(true); }} style={{ marginRight: '8px', padding: '6px 12px', background: '#f1f5f9', border: 'none', borderRadius: '6px', cursor: 'pointer', fontSize: '12px', fontWeight: '600', color: '#475569' }}>✏️ Editar</button>
                                                    <button onClick={() => handleDelete(c.id)} className="btn-danger">🗑️</button>
                                                </td>
                                            )}
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>

                    {showModal && <ClienteModal cliente={selected} onSave={handleSave} onClose={() => { setShowModal(false); setSelected(null); }} />}
                </div>
            );
        }

        function ClienteModal({ cliente, onSave, onClose }) {
            const [form, setForm] = useState(cliente || { nome: '', cpfCnpj: '', email: '', telefone: '', endereco: '', observacoes: '' });

            return (
                <div className="modal-overlay" onClick={onClose}>
                    <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                        <div style={{ padding: '24px', borderBottom: '1px solid #e2e8f0' }}>
                            <h2 style={{ fontSize: '22px', fontWeight: '800', color: '#1e293b' }}>{cliente ? 'Editar Cliente' : 'Novo Cliente'}</h2>
                        </div>
                        <form onSubmit={(e) => { e.preventDefault(); onSave(form); }} style={{ padding: '24px' }}>
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '16px' }}>
                                <div>
                                    <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Nome *</label>
                                    <input className="input-field" value={form.nome} onChange={(e) => setForm({...form, nome: e.target.value})} required />
                                </div>
                                <div>
                                    <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>CPF/CNPJ *</label>
                                    <input className="input-field" value={form.cpfCnpj} onChange={(e) => setForm({...form, cpfCnpj: e.target.value})} required />
                                </div>
                            </div>
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '16px' }}>
                                <div>
                                    <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Email</label>
                                    <input type="email" className="input-field" value={form.email} onChange={(e) => setForm({...form, email: e.target.value})} />
                                </div>
                                <div>
                                    <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Telefone</label>
                                    <input className="input-field" value={form.telefone} onChange={(e) => setForm({...form, telefone: e.target.value})} />
                                </div>
                            </div>
                            <div style={{ marginBottom: '16px' }}>
                                <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Endereço</label>
                                <input className="input-field" value={form.endereco} onChange={(e) => setForm({...form, endereco: e.target.value})} />
                            </div>
                            <div style={{ marginBottom: '20px' }}>
                                <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Observações</label>
                                <textarea className="input-field" value={form.observacoes} onChange={(e) => setForm({...form, observacoes: e.target.value})} rows="3"></textarea>
                            </div>
                            <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end' }}>
                                <button type="button" className="btn-secondary" onClick={onClose}>Cancelar</button>
                                <button type="submit" className="btn-primary">Salvar</button>
                            </div>
                        </form>
                    </div>
                </div>
            );
        }

        // DEMANDAS COM WORKFLOW
        function Demandas({ currentUser }) {
            const [demandas, setDemandas] = useState([]);
            const [clientes, setClientes] = useState([]);
            const [showModal, setShowModal] = useState(false);
            const [selected, setSelected] = useState(null);
            const [showWorkflow, setShowWorkflow] = useState(null);

            useEffect(() => {
                loadDemandas();
                setClientes(JSON.parse(storage.get('clientes_list')?.value || '[]'));
            }, []);

            const loadDemandas = () => {
                setDemandas(JSON.parse(storage.get('demandas_list')?.value || '[]'));
            };

            const canEdit = currentUser.perfil === 'admin' || currentUser.permissoes.demandas === 'editar';

            const handleSave = (demanda) => {
                const list = JSON.parse(storage.get('demandas_list')?.value || '[]');
                if (selected) {
                    const idx = list.findIndex(d => d.id === demanda.id);
                    list[idx] = demanda;
                } else {
                    list.push({ ...demanda, id: Date.now().toString(), criadoEm: new Date().toISOString(), criadoPor: currentUser.nome, etapas: [] });
                }
                storage.set('demandas_list', JSON.stringify(list));
                loadDemandas();
                setShowModal(false);
                setSelected(null);
            };

            const handleDelete = (id) => {
                if (!confirm('Deseja excluir?')) return;
                const list = JSON.parse(storage.get('demandas_list')?.value || '[]').filter(d => d.id !== id);
                storage.set('demandas_list', JSON.stringify(list));
                loadDemandas();
            };

            const getClienteNome = (id) => clientes.find(c => c.id === id)?.nome || 'N/A';

            return (
                <div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
                        <div>
                            <h1 style={{ fontSize: '28px', fontWeight: '800', color: '#1e293b' }}>Demandas</h1>
                            <p style={{ color: '#64748b', fontSize: '14px' }}>Gerenciamento de processos e serviços</p>
                        </div>
                        {canEdit && <button className="btn-primary" onClick={() => { setSelected(null); setShowModal(true); }}>➕ Nova Demanda</button>}
                    </div>

                    <div className="card">
                        <table>
                            <thead>
                                <tr>
                                    <th>Título</th>
                                    <th>Cliente</th>
                                    <th>Tipo</th>
                                    <th>Status</th>
                                    <th>Etapas</th>
                                    <th style={{ textAlign: 'right' }}>Ações</th>
                                </tr>
                            </thead>
                            <tbody>
                                {demandas.length === 0 ? (
                                    <tr><td colSpan="6" style={{ textAlign: 'center', padding: '32px', color: '#94a3b8' }}>Nenhuma demanda cadastrada</td></tr>
                                ) : (
                                    demandas.map(d => (
                                        <tr key={d.id}>
                                            <td style={{ fontWeight: '600' }}>{d.titulo}</td>
                                            <td>{getClienteNome(d.clienteId)}</td>
                                            <td><span style={{ padding: '4px 8px', background: '#f1f5f9', borderRadius: '6px', fontSize: '12px', fontWeight: '500' }}>{d.tipo}</span></td>
                                            <td><span className={`status-badge status-${d.status}`}>{d.status}</span></td>
                                            <td>{d.etapas?.length || 0} etapas</td>
                                            <td style={{ textAlign: 'right' }}>
                                                <button onClick={() => setShowWorkflow(d)} style={{ marginRight: '8px', padding: '6px 12px', background: '#3b82f6', color: 'white', border: 'none', borderRadius: '6px', cursor: 'pointer', fontSize: '12px', fontWeight: '600' }}>📋 Workflow</button>
                                                {canEdit && (
                                                    <>
                                                        <button onClick={() => { setSelected(d); setShowModal(true); }} style={{ marginRight: '8px', padding: '6px 12px', background: '#f1f5f9', border: 'none', borderRadius: '6px', cursor: 'pointer', fontSize: '12px', fontWeight: '600', color: '#475569' }}>✏️</button>
                                                        <button onClick={() => handleDelete(d.id)} className="btn-danger">🗑️</button>
                                                    </>
                                                )}
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>

                    {showModal && <DemandaModal demanda={selected} clientes={clientes} onSave={handleSave} onClose={() => { setShowModal(false); setSelected(null); }} />}
                    {showWorkflow && <WorkflowModal demanda={showWorkflow} onClose={() => setShowWorkflow(null)} onUpdate={loadDemandas} canEdit={canEdit} />}
                </div>
            );
        }

        function DemandaModal({ demanda, clientes, onSave, onClose }) {
            const [form, setForm] = useState(demanda || { titulo: '', clienteId: '', tipo: 'INSS - Aposentadoria', status: 'pendente', descricao: '', observacoes: '' });
            const tipos = ['INSS - Aposentadoria', 'INSS - Auxílio-Doença', 'INSS - BPC/LOAS', 'INSS - Pensão', 'Jurídico - Petição', 'Jurídico - Recurso', 'Administrativo - Procuração', 'Administrativo - Contrato', 'Outros'];

            return (
                <div className="modal-overlay" onClick={onClose}>
                    <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                        <div style={{ padding: '24px', borderBottom: '1px solid #e2e8f0' }}>
                            <h2 style={{ fontSize: '22px', fontWeight: '800', color: '#1e293b' }}>{demanda ? 'Editar Demanda' : 'Nova Demanda'}</h2>
                        </div>
                        <form onSubmit={(e) => { e.preventDefault(); onSave(form); }} style={{ padding: '24px' }}>
                            <div style={{ marginBottom: '16px' }}>
                                <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Título *</label>
                                <input className="input-field" value={form.titulo} onChange={(e) => setForm({...form, titulo: e.target.value})} required />
                            </div>
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '16px' }}>
                                <div>
                                    <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Cliente *</label>
                                    <select className="input-field" value={form.clienteId} onChange={(e) => setForm({...form, clienteId: e.target.value})} required>
                                        <option value="">Selecione</option>
                                        {clientes.map(c => <option key={c.id} value={c.id}>{c.nome}</option>)}
                                    </select>
                                </div>
                                <div>
                                    <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Tipo *</label>
                                    <select className="input-field" value={form.tipo} onChange={(e) => setForm({...form, tipo: e.target.value})} required>
                                        {tipos.map(t => <option key={t} value={t}>{t}</option>)}
                                    </select>
                                </div>
                            </div>
                            <div style={{ marginBottom: '16px' }}>
                                <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Status *</label>
                                <select className="input-field" value={form.status} onChange={(e) => setForm({...form, status: e.target.value})} required>
                                    <option value="pendente">Pendente</option>
                                    <option value="ativo">Ativo</option>
                                    <option value="concluido">Concluído</option>
                                    <option value="cancelado">Cancelado</option>
                                </select>
                            </div>
                            <div style={{ marginBottom: '16px' }}>
                                <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Descrição</label>
                                <textarea className="input-field" value={form.descricao} onChange={(e) => setForm({...form, descricao: e.target.value})} rows="3"></textarea>
                            </div>
                            <div style={{ marginBottom: '20px' }}>
                                <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Observações</label>
                                <textarea className="input-field" value={form.observacoes} onChange={(e) => setForm({...form, observacoes: e.target.value})} rows="2"></textarea>
                            </div>
                            <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end' }}>
                                <button type="button" className="btn-secondary" onClick={onClose}>Cancelar</button>
                                <button type="submit" className="btn-primary">Salvar</button>
                            </div>
                        </form>
                    </div>
                </div>
            );
        }

        // MODAL DE WORKFLOW
        function WorkflowModal({ demanda, onClose, onUpdate, canEdit }) {
            const [etapas, setEtapas] = useState(demanda.etapas || []);
            const [showAddEtapa, setShowAddEtapa] = useState(false);
            const [novaEtapa, setNovaEtapa] = useState({ titulo: '', descricao: '', prazo: '', prioridade: 'media', concluida: false });

            const handleAddEtapa = () => {
                const etapa = { ...novaEtapa, id: Date.now().toString(), criadaEm: new Date().toISOString() };
                const novasEtapas = [...etapas, etapa];
                setEtapas(novasEtapas);
                salvarEtapas(novasEtapas);
                setNovaEtapa({ titulo: '', descricao: '', prazo: '', prioridade: 'media', concluida: false });
                setShowAddEtapa(false);
            };

            const handleToggleConcluida = (etapaId) => {
                const novasEtapas = etapas.map(e => e.id === etapaId ? { ...e, concluida: !e.concluida, concluidaEm: !e.concluida ? new Date().toISOString() : null } : e);
                setEtapas(novasEtapas);
                salvarEtapas(novasEtapas);
            };

            const handleDeleteEtapa = (etapaId) => {
                if (!confirm('Deseja excluir esta etapa?')) return;
                const novasEtapas = etapas.filter(e => e.id !== etapaId);
                setEtapas(novasEtapas);
                salvarEtapas(novasEtapas);
            };

            const salvarEtapas = (novasEtapas) => {
                const demandas = JSON.parse(storage.get('demandas_list')?.value || '[]');
                const idx = demandas.findIndex(d => d.id === demanda.id);
                demandas[idx].etapas = novasEtapas;
                storage.set('demandas_list', JSON.stringify(demandas));
                onUpdate();
            };

            const isAtrasada = (etapa) => {
                return !etapa.concluida && etapa.prazo && new Date(etapa.prazo) < new Date();
            };

            const etapasOrdenadas = [...etapas].sort((a, b) => {
                if (a.concluida !== b.concluida) return a.concluida ? 1 : -1;
                if (!a.prazo && !b.prazo) return 0;
                if (!a.prazo) return 1;
                if (!b.prazo) return -1;
                return new Date(a.prazo) - new Date(b.prazo);
            });

            return (
                <div className="modal-overlay" onClick={onClose}>
                    <div className="modal-content" onClick={(e) => e.stopPropagation()} style={{ maxWidth: '800px' }}>
                        <div style={{ padding: '24px', borderBottom: '1px solid #e2e8f0' }}>
                            <h2 style={{ fontSize: '22px', fontWeight: '800', color: '#1e293b', marginBottom: '4px' }}>Workflow: {demanda.titulo}</h2>
                            <p style={{ color: '#64748b', fontSize: '14px' }}>Gerencie as etapas e prazos desta demanda</p>
                        </div>
                        <div style={{ padding: '24px' }}>
                            {canEdit && (
                                <button className="btn-success" onClick={() => setShowAddEtapa(!showAddEtapa)} style={{ marginBottom: '20px' }}>
                                    {showAddEtapa ? '✖ Cancelar' : '➕ Nova Etapa'}
                                </button>
                            )}

                            {showAddEtapa && (
                                <div style={{ marginBottom: '20px', padding: '16px', background: '#f8fafc', borderRadius: '8px', border: '1px solid #e2e8f0' }}>
                                    <h3 style={{ fontSize: '16px', fontWeight: '700', marginBottom: '12px', color: '#1e293b' }}>Adicionar Etapa</h3>
                                    <div style={{ marginBottom: '12px' }}>
                                        <input className="input-field" placeholder="Título da etapa *" value={novaEtapa.titulo} onChange={(e) => setNovaEtapa({...novaEtapa, titulo: e.target.value})} />
                                    </div>
                                    <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '12px', marginBottom: '12px' }}>
                                        <input type="datetime-local" className="input-field" value={novaEtapa.prazo} onChange={(e) => setNovaEtapa({...novaEtapa, prazo: e.target.value})} />
                                        <select className="input-field" value={novaEtapa.prioridade} onChange={(e) => setNovaEtapa({...novaEtapa, prioridade: e.target.value})}>
                                            <option value="baixa">Baixa</option>
                                            <option value="media">Média</option>
                                            <option value="alta">Alta</option>
                                            <option value="urgente">Urgente</option>
                                        </select>
                                    </div>
                                    <div style={{ marginBottom: '12px' }}>
                                        <textarea className="input-field" placeholder="Descrição (opcional)" rows="2" value={novaEtapa.descricao} onChange={(e) => setNovaEtapa({...novaEtapa, descricao: e.target.value})}></textarea>
                                    </div>
                                    <button className="btn-success" onClick={handleAddEtapa} disabled={!novaEtapa.titulo}>Adicionar Etapa</button>
                                </div>
                            )}

                            <div style={{ maxHeight: '500px', overflowY: 'auto' }}>
                                {etapasOrdenadas.length === 0 ? (
                                    <div style={{ textAlign: 'center', padding: '48px', color: '#94a3b8' }}>
                                        <div style={{ fontSize: '48px', marginBottom: '16px' }}>📋</div>
                                        <p>Nenhuma etapa cadastrada</p>
                                    </div>
                                ) : (
                                    etapasOrdenadas.map((etapa, idx) => (
                                        <div key={etapa.id} className={`workflow-step ${etapa.concluida ? 'concluida' : isAtrasada(etapa) ? 'atrasada' : ''}`}>
                                            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start' }}>
                                                <div style={{ flex: 1 }}>
                                                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '8px' }}>
                                                        {canEdit && (
                                                            <input 
                                                                type="checkbox" 
                                                                checked={etapa.concluida} 
                                                                onChange={() => handleToggleConcluida(etapa.id)}
                                                                style={{ width: '20px', height: '20px', cursor: 'pointer' }}
                                                            />
                                                        )}
                                                        <h4 style={{ fontSize: '16px', fontWeight: '700', color: '#1e293b', textDecoration: etapa.concluida ? 'line-through' : 'none' }}>
                                                            {etapa.titulo}
                                                        </h4>
                                                        {etapa.prioridade === 'urgente' && <span style={{ padding: '2px 8px', background: '#fee2e2', color: '#dc2626', borderRadius: '4px', fontSize: '11px', fontWeight: '600' }}>URGENTE</span>}
                                                        {etapa.prioridade === 'alta' && <span style={{ padding: '2px 8px', background: '#fef3c7', color: '#ca8a04', borderRadius: '4px', fontSize: '11px', fontWeight: '600' }}>ALTA</span>}
                                                    </div>
                                                    {etapa.descricao && <p style={{ fontSize: '14px', color: '#64748b', marginBottom: '8px' }}>{etapa.descricao}</p>}
                                                    <div style={{ display: 'flex', gap: '16px', fontSize: '13px', color: '#64748b' }}>
                                                        {etapa.prazo && (
                                                            <span>
                                                                📅 Prazo: {new Date(etapa.prazo).toLocaleDateString('pt-BR')} às {new Date(etapa.prazo).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}
                                                                {isAtrasada(etapa) && <span style={{ color: '#ef4444', fontWeight: '600', marginLeft: '8px' }}>⚠️ ATRASADO</span>}
                                                            </span>
                                                        )}
                                                    </div>
                                                    {etapa.concluida && etapa.concluidaEm && (
                                                        <div style={{ marginTop: '8px', padding: '8px', background: '#f0fdf4', borderRadius: '6px', fontSize: '12px', color: '#16a34a' }}>
                                                            ✓ Concluída em {new Date(etapa.concluidaEm).toLocaleDateString('pt-BR')} às {new Date(etapa.concluidaEm).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}
                                                        </div>
                                                    )}
                                                </div>
                                                {canEdit && (
                                                    <button onClick={() => handleDeleteEtapa(etapa.id)} className="btn-danger" style={{ padding: '6px 12px', fontSize: '12px' }}>🗑️</button>
                                                )}
                                            </div>
                                        </div>
                                    ))
                                )}
                            </div>

                            <div style={{ marginTop: '24px', paddingTop: '20px', borderTop: '1px solid #e2e8f0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                <div style={{ fontSize: '14px', color: '#64748b' }}>
                                    <strong>{etapas.filter(e => e.concluida).length}</strong> de <strong>{etapas.length}</strong> etapas concluídas
                                </div>
                                <button className="btn-secondary" onClick={onClose}>Fechar</button>
                            </div>
                        </div>
                    </div>
                </div>
            );
        }

        // USUÁRIOS E PERFIL (versões simplificadas mantidas do código original)
        function Usuarios({ currentUser }) {
            const [usuarios, setUsuarios] = useState([]);
            const [showModal, setShowModal] = useState(false);
            const [selected, setSelected] = useState(null);

            useEffect(() => { loadUsuarios(); }, []);

            const loadUsuarios = () => setUsuarios(JSON.parse(storage.get('users_list')?.value || '[]'));
            const canEdit = currentUser.perfil === 'admin' || currentUser.permissoes.usuarios === 'editar';

            if (!canEdit) {
                return (
                    <div>
                        <h1 style={{ fontSize: '28px', fontWeight: '800', color: '#1e293b', marginBottom: '8px' }}>Usuários</h1>
                        <div className="card" style={{ padding: '48px', textAlign: 'center' }}>
                            <p style={{ color: '#64748b', fontSize: '16px' }}>Você não tem permissão para acessar esta seção.</p>
                        </div>
                    </div>
                );
            }

            const handleSave = (usuario) => {
                const list = JSON.parse(storage.get('users_list')?.value || '[]');
                if (selected) {
                    const idx = list.findIndex(u => u.id === usuario.id);
                    if (!usuario.senha) usuario.senha = list[idx].senha;
                    list[idx] = usuario;
                } else {
                    list.push({ ...usuario, id: Date.now().toString(), criadoEm: new Date().toISOString() });
                }
                storage.set('users_list', JSON.stringify(list));
                loadUsuarios();
                setShowModal(false);
                setSelected(null);
            };

            const handleDelete = (id) => {
                if (id === currentUser.id) { alert('Você não pode excluir seu próprio usuário'); return; }
                if (!confirm('Deseja excluir?')) return;
                const list = JSON.parse(storage.get('users_list')?.value || '[]').filter(u => u.id !== id);
                storage.set('users_list', JSON.stringify(list));
                loadUsuarios();
            };

            return (
                <div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
                        <div>
                            <h1 style={{ fontSize: '28px', fontWeight: '800', color: '#1e293b' }}>Usuários</h1>
                            <p style={{ color: '#64748b', fontSize: '14px' }}>Gerenciamento de usuários e permissões</p>
                        </div>
                        <button className="btn-primary" onClick={() => { setSelected(null); setShowModal(true); }}>➕ Novo Usuário</button>
                    </div>

                    <div className="card">
                        <table>
                            <thead>
                                <tr><th>Nome</th><th>Usuário</th><th>Perfil</th><th>Status</th><th>Cadastrado</th><th style={{ textAlign: 'right' }}>Ações</th></tr>
                            </thead>
                            <tbody>
                                {usuarios.map(u => (
                                    <tr key={u.id}>
                                        <td style={{ fontWeight: '600' }}>{u.nome}</td>
                                        <td>@{u.usuario}</td>
                                        <td><span className={`status-badge ${u.perfil === 'admin' ? 'status-ativo' : 'status-pendente'}`}>{u.perfil === 'admin' ? 'Admin' : 'Usuário'}</span></td>
                                        <td><span className={`status-badge ${u.ativo ? 'status-ativo' : 'status-cancelado'}`}>{u.ativo ? 'Ativo' : 'Inativo'}</span></td>
                                        <td>{new Date(u.criadoEm).toLocaleDateString('pt-BR')}</td>
                                        <td style={{ textAlign: 'right' }}>
                                            <button onClick={() => { setSelected(u); setShowModal(true); }} style={{ marginRight: '8px', padding: '6px 12px', background: '#f1f5f9', border: 'none', borderRadius: '6px', cursor: 'pointer', fontSize: '12px', fontWeight: '600', color: '#475569' }}>✏️</button>
                                            {u.id !== currentUser.id && <button onClick={() => handleDelete(u.id)} className="btn-danger">🗑️</button>}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>

                    {showModal && <UsuarioModal usuario={selected} onSave={handleSave} onClose={() => { setShowModal(false); setSelected(null); }} />}
                </div>
            );
        }

        function UsuarioModal({ usuario, onSave, onClose }) {
            const [form, setForm] = useState(usuario || { nome: '', usuario: '', senha: '', perfil: 'usuario', ativo: true, permissoes: { clientes: 'visualizar', demandas: 'visualizar', usuarios: 'nenhum', relatorios: 'visualizar' } });

            return (
                <div className="modal-overlay" onClick={onClose}>
                    <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                        <div style={{ padding: '24px', borderBottom: '1px solid #e2e8f0' }}>
                            <h2 style={{ fontSize: '22px', fontWeight: '800', color: '#1e293b' }}>{usuario ? 'Editar Usuário' : 'Novo Usuário'}</h2>
                        </div>
                        <form onSubmit={(e) => { e.preventDefault(); onSave(form); }} style={{ padding: '24px' }}>
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '16px' }}>
                                <div>
                                    <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Nome *</label>
                                    <input className="input-field" value={form.nome} onChange={(e) => setForm({...form, nome: e.target.value})} required />
                                </div>
                                <div>
                                    <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Usuário *</label>
                                    <input className="input-field" value={form.usuario} onChange={(e) => setForm({...form, usuario: e.target.value})} required />
                                </div>
                            </div>
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '16px' }}>
                                <div>
                                    <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Senha {usuario ? '(deixe vazio para manter)' : '*'}</label>
                                    <input type="password" className="input-field" value={form.senha} onChange={(e) => setForm({...form, senha: e.target.value})} required={!usuario} />
                                </div>
                                <div>
                                    <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Perfil *</label>
                                    <select className="input-field" value={form.perfil} onChange={(e) => setForm({...form, perfil: e.target.value})} required>
                                        <option value="usuario">Usuário</option>
                                        <option value="admin">Administrador</option>
                                    </select>
                                </div>
                            </div>
                            <div style={{ marginBottom: '16px' }}>
                                <label style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
                                    <input type="checkbox" checked={form.ativo} onChange={(e) => setForm({...form, ativo: e.target.checked})} style={{ width: '18px', height: '18px' }} />
                                    <span style={{ fontWeight: '600', color: '#475569', fontSize: '14px' }}>Usuário Ativo</span>
                                </label>
                            </div>
                            <div style={{ marginBottom: '20px', padding: '16px', background: '#f8fafc', borderRadius: '8px' }}>
                                <h3 style={{ fontSize: '15px', fontWeight: '700', marginBottom: '12px', color: '#1e293b' }}>Permissões</h3>
                                {Object.keys(form.permissoes).map(key => (
                                    <div key={key} style={{ marginBottom: '12px' }}>
                                        <label style={{ display: 'block', marginBottom: '4px', fontWeight: '600', color: '#475569', fontSize: '13px', textTransform: 'capitalize' }}>{key}</label>
                                        <select className="input-field" value={form.permissoes[key]} onChange={(e) => setForm({ ...form, permissoes: { ...form.permissoes, [key]: e.target.value } })}>
                                            <option value="nenhum">Nenhum</option>
                                            <option value="visualizar">Visualizar</option>
                                            <option value="editar">Editar</option>
                                        </select>
                                    </div>
                                ))}
                            </div>
                            <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end' }}>
                                <button type="button" className="btn-secondary" onClick={onClose}>Cancelar</button>
                                <button type="submit" className="btn-primary">Salvar</button>
                            </div>
                        </form>
                    </div>
                </div>
            );
        }

        function Perfil({ currentUser }) {
            const [form, setForm] = useState({ nome: currentUser.nome, usuario: currentUser.usuario, senhaAtual: '', novaSenha: '', confirmarSenha: '' });
            const [message, setMessage] = useState({ type: '', text: '' });
            const isAdmin = currentUser.perfil === 'admin';

            const handleSubmit = (e) => {
                e.preventDefault();
                setMessage({ type: '', text: '' });

                const users = JSON.parse(storage.get('users_list')?.value || '[]');
                const userIdx = users.findIndex(u => u.id === currentUser.id);
                if (userIdx === -1) { setMessage({ type: 'error', text: 'Usuário não encontrado' }); return; }

                const usuario = users[userIdx];

                if (form.novaSenha) {
                    if (form.senhaAtual !== usuario.senha) { setMessage({ type: 'error', text: 'Senha atual incorreta' }); return; }
                    if (form.novaSenha !== form.confirmarSenha) { setMessage({ type: 'error', text: 'Senhas não coincidem' }); return; }
                    usuario.senha = form.novaSenha;
                }

                if (isAdmin) {
                    if (form.usuario !== currentUser.usuario && users.some(u => u.usuario === form.usuario && u.id !== currentUser.id)) {
                        setMessage({ type: 'error', text: 'Usuário já existe' });
                        return;
                    }
                    usuario.nome = form.nome;
                    usuario.usuario = form.usuario;
                }

                users[userIdx] = usuario;
                storage.set('users_list', JSON.stringify(users));
                storage.set('current_user', JSON.stringify(usuario));
                setMessage({ type: 'success', text: 'Perfil atualizado!' });
                setTimeout(() => window.location.reload(), 1500);
            };

            return (
                <div style={{ maxWidth: '700px' }}>
                    <div style={{ marginBottom: '24px' }}>
                        <h1 style={{ fontSize: '28px', fontWeight: '800', color: '#1e293b' }}>Meu Perfil</h1>
                        <p style={{ color: '#64748b', fontSize: '14px' }}>Gerencie suas informações pessoais</p>
                    </div>

                    <div className="card">
                        <div style={{ display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '24px', paddingBottom: '20px', borderBottom: '1px solid #e2e8f0' }}>
                            <div style={{ width: '60px', height: '60px', background: '#3b82f6', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '28px', fontWeight: '700', color: 'white' }}>
                                {currentUser.nome.charAt(0).toUpperCase()}
                            </div>
                            <div>
                                <h2 style={{ fontSize: '20px', fontWeight: '700', color: '#1e293b' }}>{currentUser.nome}</h2>
                                <p style={{ color: '#64748b', fontSize: '14px' }}>@{currentUser.usuario}</p>
                                <span className={`status-badge ${currentUser.perfil === 'admin' ? 'status-ativo' : 'status-pendente'}`} style={{ marginTop: '6px' }}>
                                    {currentUser.perfil === 'admin' ? 'Administrador' : 'Usuário'}
                                </span>
                            </div>
                        </div>

                        <form onSubmit={handleSubmit}>
                            {isAdmin && (
                                <div style={{ marginBottom: '20px', padding: '16px', background: '#f8fafc', borderRadius: '8px' }}>
                                    <h3 style={{ fontSize: '16px', fontWeight: '700', marginBottom: '12px', color: '#1e293b' }}>Informações Básicas</h3>
                                    <div style={{ marginBottom: '12px' }}>
                                        <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Nome</label>
                                        <input className="input-field" value={form.nome} onChange={(e) => setForm({...form, nome: e.target.value})} required />
                                    </div>
                                    <div>
                                        <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Usuário</label>
                                        <input className="input-field" value={form.usuario} onChange={(e) => setForm({...form, usuario: e.target.value})} required />
                                    </div>
                                </div>
                            )}

                            <div style={{ marginBottom: '20px', padding: '16px', background: '#fffbeb', borderRadius: '8px', border: '1px solid #fde047' }}>
                                <h3 style={{ fontSize: '16px', fontWeight: '700', marginBottom: '12px', color: '#1e293b' }}>Alterar Senha</h3>
                                <div style={{ marginBottom: '12px' }}>
                                    <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Senha Atual</label>
                                    <input type="password" className="input-field" value={form.senhaAtual} onChange={(e) => setForm({...form, senhaAtual: e.target.value})} />
                                </div>
                                <div style={{ marginBottom: '12px' }}>
                                    <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Nova Senha</label>
                                    <input type="password" className="input-field" value={form.novaSenha} onChange={(e) => setForm({...form, novaSenha: e.target.value})} />
                                </div>
                                <div>
                                    <label style={{ display: 'block', marginBottom: '6px', fontWeight: '600', color: '#475569', fontSize: '13px' }}>Confirmar Nova Senha</label>
                                    <input type="password" className="input-field" value={form.confirmarSenha} onChange={(e) => setForm({...form, confirmarSenha: e.target.value})} />
                                </div>
                            </div>

                            {message.text && (
                                <div style={{ background: message.type === 'success' ? '#f0fdf4' : '#fef2f2', border: `1px solid ${message.type === 'success' ? '#86efac' : '#fca5a5'}`, color: message.type === 'success' ? '#16a34a' : '#dc2626', padding: '12px', borderRadius: '8px', marginBottom: '16px', fontSize: '14px' }}>
                                    {message.text}
                                </div>
                            )}

                            <button type="submit" className="btn-primary">💾 Salvar Alterações</button>
                        </form>
                    </div>
                </div>
            );
        }

        ReactDOM.render(<App />, document.getElementById('root'));
    </script>
</body>
</html>
