# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Org.create(
  [
    { name: '会社_a', org_type: :ordering_org },
    { name: '会社_b', org_type: :buying_org },
    { name: '会社_c', org_type: :ordering_org }
  ]
)

org_a = Org.find_by(name: '会社_a')
org_b = Org.find_by(name: '会社_b')

ec_shop_buyma = org_a.ec_shops.create(org: org_a, ec_shop_type: :buyma)

ec_shop_buyma.suppliers.create(
  [
    { item_number: 'seed-item-1000' },
    { item_number: 'seed-item-2000' },
    { item_number: 'seed-item-3000' },
    { item_number: 'seed-item-4000' },
    { item_number: 'seed-item-5000' },
    { item_number: 'seed-item-6000' },
    { item_number: 'seed-item-7000' },
    { item_number: 'seed-item-8000' },
    { item_number: 'seed-item-9000' }
  ]
)

indexed_suppliers_by_id = ec_shop_buyma.suppliers.index_by(&:item_number)

ec_shop_buyma.orders.create(
  [
    {
      supplier: indexed_suppliers_by_id.fetch('seed-item-1000'),
      trade_number: 'seed-trade-1000',
      title: '◯◯◯◯◯◯◯◯◯◯',
      postal: 'XXX-XXXX',
      address: '◯◯県◯◯市◯◯区◯丁目◯◯-◯◯',
      addressee: 'YYYYYY',
      phone: 'XXX-XXXX-XXXX',
      color_size: '△△△',
      quantity: 1,
      selling_unit_price: 10_000,
      information: '△△△',
      memo: 'XXX',
      status: :before_order,
      buying_org_id: org_b.id
    },
    {
      supplier: indexed_suppliers_by_id.fetch('seed-item-2000'),
      trade_number: 'seed-trade-2000',
      title: '◯◯◯◯◯◯◯◯◯◯',
      postal: 'XXX-XXXX',
      address: '◯◯県◯◯市◯◯区◯丁目◯◯-◯◯',
      addressee: 'YYYYYY',
      phone: 'XXX-XXXX-XXXX',
      color_size: '△△△',
      quantity: 1,
      selling_unit_price: 10_000,
      information: '△△△',
      memo: 'XXX',
      status: :ordered,
      buying_org_id: org_b.id
    },
    {
      supplier: indexed_suppliers_by_id.fetch('seed-item-3000'),
      trade_number: 'seed-trade-3000',
      title: '◯◯◯◯◯◯◯◯◯◯',
      postal: 'XXX-XXXX',
      address: '◯◯県◯◯市◯◯区◯丁目◯◯-◯◯',
      addressee: 'YYYYYY',
      phone: 'XXX-XXXX-XXXX',
      color_size: '△△△',
      quantity: 1,
      selling_unit_price: 10_000,
      information: '△△△',
      memo: 'XXX',
      status: :buying,
      buying_org_id: org_b.id
    },
    {
      supplier: indexed_suppliers_by_id.fetch('seed-item-4000'),
      trade_number: 'seed-trade-4000',
      title: '◯◯◯◯◯◯◯◯◯◯',
      postal: 'XXX-XXXX',
      address: '◯◯県◯◯市◯◯区◯丁目◯◯-◯◯',
      addressee: 'YYYYYY',
      phone: 'XXX-XXXX-XXXX',
      color_size: '△△△',
      quantity: 1,
      selling_unit_price: 10_000,
      information: '△△△',
      memo: 'XXX',
      status: :shipped,
      buying_org_id: org_b.id
    },
    {
      supplier: indexed_suppliers_by_id.fetch('seed-item-5000'),
      trade_number: 'seed-trade-5000',
      title: '◯◯◯◯◯◯◯◯◯◯',
      postal: 'XXX-XXXX',
      address: '◯◯県◯◯市◯◯区◯丁目◯◯-◯◯',
      addressee: 'YYYYYY',
      phone: 'XXX-XXXX-XXXX',
      color_size: '△△△',
      quantity: 1,
      selling_unit_price: 10_000,
      information: '△△△',
      memo: 'XXX',
      status: :before_order,
      buying_org_id: org_b.id
    },
    {
      supplier: indexed_suppliers_by_id.fetch('seed-item-6000'),
      trade_number: 'seed-trade-6000',
      title: '◯◯◯◯◯◯◯◯◯◯',
      postal: 'XXX-XXXX',
      address: '◯◯県◯◯市◯◯区◯丁目◯◯-◯◯',
      addressee: 'YYYYYY',
      phone: 'XXX-XXXX-XXXX',
      color_size: '△△△',
      quantity: 1,
      selling_unit_price: 10_000,
      information: '△△△',
      memo: 'XXX',
      status: :ordered,
      buying_org_id: org_b.id
    },
    {
      supplier: indexed_suppliers_by_id.fetch('seed-item-7000'),
      trade_number: 'seed-trade-7000',
      title: '◯◯◯◯◯◯◯◯◯◯',
      postal: 'XXX-XXXX',
      address: '◯◯県◯◯市◯◯区◯丁目◯◯-◯◯',
      addressee: 'YYYYYY',
      phone: 'XXX-XXXX-XXXX',
      color_size: '△△△',
      quantity: 1,
      selling_unit_price: 10_000,
      information: '△△△',
      memo: 'XXX',
      status: :buying,
      buying_org_id: org_b.id
    },
    {
      supplier: indexed_suppliers_by_id.fetch('seed-item-8000'),
      trade_number: 'seed-trade-8000',
      title: '◯◯◯◯◯◯◯◯◯◯',
      postal: 'XXX-XXXX',
      address: '◯◯県◯◯市◯◯区◯丁目◯◯-◯◯',
      addressee: 'YYYYYY',
      phone: 'XXX-XXXX-XXXX',
      color_size: '△△△',
      quantity: 1,
      selling_unit_price: 10_000,
      information: '△△△',
      memo: 'XXX',
      status: :shipped,
      buying_org_id: org_b.id
    },
    {
      supplier: indexed_suppliers_by_id.fetch('seed-item-9000'),
      trade_number: 'seed-trade-9000',
      title: '◯◯◯◯◯◯◯◯◯◯',
      postal: 'XXX-XXXX',
      address: '◯◯県◯◯市◯◯区◯丁目◯◯-◯◯',
      addressee: 'YYYYYY',
      phone: 'XXX-XXXX-XXXX',
      color_size: '△△△',
      quantity: 1,
      selling_unit_price: 10_000,
      information: '△△△',
      memo: 'XXX',
      status: :before_order,
      buying_org_id: org_b.id
    }
  ]
)
