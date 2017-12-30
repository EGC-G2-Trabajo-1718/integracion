start transaction;

create database `AdministracionVotaciones` character set UTF8;

use `AdministracionVotaciones`;

create user 'acme-user'@'%' identified by password '*4F10007AADA9EE3DBB2CC36575DFC6F4FDE27577';
create user 'acme-manager'@'%' identified by password '*FDB8CD304EB2317D10C95D797A4BD7492560F55F';

grant select, insert, update, delete 
	on `AdministracionVotaciones`.* to 'acme-user'@'%';

grant select, insert, update, delete, create, drop, references, index, alter, 
        create temporary tables, lock tables, create view, create routine, 
        alter routine, execute, trigger, show view
    on `AdministracionVotaciones`.* to 'acme-manager'@'%';

create database `autenticacion` character set UTF8;

create user 'auth-user'@'%' identified by password '*D4729648115A359469A493B06F9BF7071EAE3D62';

grant all privileges on `autenticacion`.* to 'auth-user'@'%';

create database `adm_censos` character set UTF8;

create user 'censos-user'@'%' identified by password '*D4729648115A359469A493B06F9BF7071EAE3D62';

grant all privileges on `adm_censos`.* to 'censos-user'@'%';

create database `almacenamiento` character set UTF8;

create user 'alm-user'@'%' identified by password '*D4729648115A359469A493B06F9BF7071EAE3D62';

grant all privileges on `almacenamiento`.* to 'alm-user'@'%';

create database `recuento` character set UTF8;

create user 'rec-user'@'%' identified by password '*D4729648115A359469A493B06F9BF7071EAE3D62';

grant all privileges on `recuento`.* to 'rec-user'@'%';

commit;
