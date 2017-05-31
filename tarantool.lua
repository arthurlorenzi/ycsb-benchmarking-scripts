-- definicao de configuracoes para servidor
box.cfg{
    listen             = 3301,
    slab_alloc_arena   = 2.5,
    slab_alloc_minimal = 512
}

-- destroi o space 'ycsb' caso ja exista
s = box.space.ycsb;
if s ~= null then
	s:drop()
end

s = box.schema.space.create('ycsb', { id = tonumber(arg[1]) } )
-- criacao do index para o benchmark
i = s:create_index('primary', {type = 'hash', parts = {1, 'STR'}})
-- autorizar todas operações para o usuário guest
box.schema.user.grant('guest', 'read,write,execute', 'universe', nil, { if_not_exists = true })
-- inicia o console do Tarantool
require('console').start()
