create table users
(
    user_id       bigserial
        constraint user_pk
            primary key,
    registered_at timestamp default CURRENT_TIMESTAMP not null
);


create table user_authority
(
    id        bigint not null
        constraint user_authority_pk
            primary key,
    user_id   bigint not null
        constraint user_authority_users_user_id_fk
            references users,
    authority text   not null
);

create table auth_code
(
    id                  bigserial
        constraint auth_code_pk
            primary key,
    code                text      not null
        constraint auth_code_uq_code
            unique,
    verification_id     text      not null
        constraint auth_code_uq_verification_id
            unique,
    status              text      not null,
    approved_by_user_id bigint
        constraint auth_code_fk_user_id
            references users,
    expire_at           timestamp not null,
    external_id         bigint
);

create table auth_phone
(
    id      bigserial
        constraint auth_phone_pk
            primary key,
    phone   text   not null,
    user_id bigint not null
        constraint auth_phone_fk_user_id
            references users
);

create table phone_code
(
    id             bigserial
        constraint phone_code_pk
            primary key,
    phone          text      not null,
    code           text      not null,
    attempt_number integer   not null,
    expire_at      timestamp not null
);

create table individual_info
(
    id             bigserial
        constraint individual_info_pk
            primary key,
    last_name      text,
    first_name     text,
    patronymic     text,
    phone          text,
    contact_email  text,
    user_id        bigint not null
        constraint individual_info_fk_user_id
            references users,
    avatar_file_id text,
    type           varchar(255) default 'IP'::character varying
);

create table establishment
(
    id               bigserial
        constraint establishment_pk
            primary key,
    name             varchar(255)     not null,
    address          varchar(255)     not null,
    area             double precision not null,
    layout_file_id   varchar(255),
    user_id          bigint           not null
        constraint establishment_users_user_id_fk
            references users,
    layout_file_size bigint default 0
);

create table organization_info
(
    id           bigserial
        constraint organization_info_pk
            primary key,
    inn          text,
    kpp          text,
    address      text,
    ogrn         text,
    user_id      bigint                                                 not null
        constraint organization_info_fk_user_id
            references users,
    company_name text,
    email        varchar(255),
    fio          varchar(255),
    okvd         text,
    type         varchar(255) default 'LEGAL_ENTITY'::character varying not null
);

create table playlist
(
    id                      bigserial
        constraint playlist_pk
            primary key,
    avatar_file_id          text,
    name                    text,
    description             text,
    year                    smallint,
    added_by_user_id        bigint                                              not null
        constraint playlist_fk_added_by_user_id
            references users,
    summary_track_file_id   text,
    title_color             varchar(32)  default '#000000'::character varying,
    status                  varchar(255) default 'PUBLISHED'::character varying not null,
    version                 smallint     default 1                              not null,
    summary_track_file_name text,
    deleted                 boolean      default false                          not null
);

create table player
(
    id                bigserial
        constraint player_pk
            primary key,
    owner_user_id     bigint           not null
        constraint player_fk_user_id
            references users,
    type              text,
    name              text,
    address           text,
    serial_box_number text,
    establishment_id  bigint default 1 not null
        constraint player_establishment_id_fk
            references establishment,
    version           text,
    player_id         bigint
        constraint player_player_id_fk
            references player
);

create table schedule
(
    id                 bigserial
        constraint schedule_pk
            primary key,
    weekdays           text not null,
    start_time         time,
    end_time           time,
    playlist_id        bigint
        constraint fk_schedule_playlist_id
            references playlist
            on delete cascade,
    start_weekend_time time,
    end_weekend_time   time,
    establishment_id   bigint
        constraint schedule_establishment_id_fk
            references establishment,
    timezone           varchar(255)
);

create table tariff
(
    id                 bigserial
        constraint tariff_pk
            primary key,
    name               varchar(255)       not null,
    description        text,
    type               varchar(255)       not null,
    price              double precision   not null,
    active             boolean            not null,
    created_by_user_id bigint
        constraint tariff_users_user_id_fk
            references users,
    "order"            smallint default 0 not null
);

create table tariff_feature
(
    id        bigserial
        constraint feature_pk
            primary key,
    name      varchar(255) not null,
    recurrent boolean      not null,
    tariff_id bigint       not null
        constraint feature_tariff_id_fk
            references tariff
);

create table tariff_sub_feature
(
    id                bigserial
        constraint tariff_sub_feature_pk
            primary key,
    name              varchar(255)     not null,
    approval_required boolean          not null,
    price             double precision not null,
    tariff_feature_id bigint           not null
        constraint tariff_sub_feature_tariff_feature_id_fk
            references tariff_feature
);


create table tariff_playlist
(
    id          bigserial
        constraint tariff_playlist_pk
            primary key,
    tariff_id   bigint not null
        constraint tariff_playlist_tariff_id_fk
            references tariff
            on update cascade on delete cascade,
    playlist_id bigint not null
        constraint tariff_playlist_playlist_id_fk
            references playlist
            on update cascade on delete cascade,
    user_id     bigint
        constraint tariff_playlist_users_user_id_fk
            references users
            on update cascade on delete cascade
);

create table subscription
(
    id                   bigserial
        constraint subscription_pk
            primary key,
    created_at           timestamp        not null,
    establishment_id     bigint           not null
        constraint subscription_pk_2
            unique
        constraint subscription___fk
            references establishment,
    tariff_id            bigint           not null
        constraint subscription___fk_2
            references tariff,
    user_id              bigint           not null
        constraint subscription___fk_3
            references users,
    price                double precision not null,
    active               boolean          not null,
    start_date           timestamp        not null,
    end_date             timestamp        not null,
    organization_info_id bigint
        constraint subscription_organization_info_id_fk
            references organization_info,
    payment_account_id   bigint,
    payment_card_id      bigint
);

create table payment
(
    id              bigserial
        constraint payment_pk
            primary key,
    name            varchar(255),
    datetime        timestamp             not null,
    price           double precision      not null,
    status          varchar(64)           not null,
    payment_id      varchar(64)           not null,
    order_id        varchar(64)           not null,
    user_id         bigint                not null
        constraint payment_users_user_id_fk
            references users,
    recurrent       boolean default false not null,
    rebill_id       bigint,
    subscription_id bigint                not null
        constraint payment___fk
            references subscription
);

create table receipt
(
    id         bigint                                     not null
        constraint receipt_pk
            primary key,
    url        varchar(512) default ''::character varying not null,
    payment_id bigint                                     not null
        constraint receipt_payment_id_fk
            references payment
);

create table subscription_tariff_sub_feature
(
    subscription_id       bigint not null
        constraint table_name_subscription_id_fk
            references subscription
            on update cascade on delete cascade,
    tariff_sub_feature_id bigint not null
        constraint table_name_tariff_sub_feature_id_fk
            references tariff_sub_feature
            on update cascade on delete cascade
);

create table payment_card
(
    id                   bigserial
        constraint payment_card_pk
            primary key,
    external_card_id     varchar(255) not null,
    pan                  varchar(255) not null,
    bank_logo_url        text,
    organization_info_id bigint       not null
        constraint payment_card_organization_info_id_fk
            references organization_info
            on update cascade on delete cascade,
    owner_user_id        bigint       not null
        constraint payment_card_users_user_id_fk
            references users
            on update cascade on delete cascade,
    re_bill_id           bigint
);

create table payment_account
(
    id                   bigserial
        constraint payment_account_pk
            primary key,
    account_number       varchar(255) not null,
    bank_branch_name     text         not null,
    bank_branch_address  text         not null,
    bank_bik             varchar(255) not null,
    correspondent_number varchar(255) not null,
    organization_info_id bigint       not null
        constraint payment_account_organization_info_id_fk
            references organization_info
            on update cascade on delete cascade,
    owner_user_id        bigint       not null
        constraint payment_account_users_id_fk
            references users
            on update cascade on delete cascade
);

