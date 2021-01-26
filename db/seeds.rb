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

orders = Order.create(
  [
    {
      item_no: '21942661',
      trade_no: '97547563',
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
      status: 1,
      ordering_org_id: org_a.id,
      buying_org_id: org_b.id
    },
    {
      item_no: '43042644',
      trade_no: '56654093',
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
      status: 2,
      ordering_org_id: org_a.id,
      buying_org_id: org_b.id
    },
    {
      item_no: '81366219',
      trade_no: '46263602',
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
      status: 3,
      ordering_org_id: org_a.id,
      buying_org_id: org_b.id
    },
    {
      item_no: '60941267',
      trade_no: '76537895',
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
      status: 4,
      ordering_org_id: org_a.id,
      buying_org_id: org_b.id
    },
    {
      item_no: '57200273',
      trade_no: '56939175',
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
      status: 1,
      ordering_org_id: org_a.id,
      buying_org_id: org_b.id
    },
    {
      item_no: '56913758',
      trade_no: '83265169',
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
      status: 2,
      ordering_org_id: org_a.id,
      buying_org_id: org_b.id
    },
    {
      item_no: '39821252',
      trade_no: '68545632',
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
      status: 3,
      ordering_org_id: org_a.id,
      buying_org_id: org_b.id
    },
    {
      item_no: '15498805',
      trade_no: '86154160',
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
      status: 4,
      ordering_org_id: org_a.id,
      buying_org_id: org_b.id
    },
    {
      item_no: '72699536',
      trade_no: '73779350',
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
      status: 1,
      ordering_org_id: org_a.id,
      buying_org_id: org_b.id
    },
    {
      item_no: '39959859',
      trade_no: '16022030',
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
      status: 2,
      ordering_org_id: org_a.id,
      buying_org_id: org_b.id
    },
    {
      item_no: '83715346',
      trade_no: '48758961',
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
      status: 3,
      ordering_org_id: org_a.id,
      buying_org_id: org_b.id
    },
    {
      item_no: '42550477',
      trade_no: '94813841',
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
      status: 4,
      ordering_org_id: org_a.id,
      buying_org_id: org_b.id
    },
    {
      item_no: '56606457',
      trade_no: '79330602',
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
      status: 1,
      ordering_org_id: org_a.id,
      buying_org_id: org_b.id
    }
  ]
)

supplier_url = org_a.supplier_urls.create(url: 'https://www.google.com/')

orders.each do |order|
  actual_unit = order.create_actual_unit
  actual_unit.tap do |unit|
    unit.actual_unit_urls.create(supplier_url: supplier_url)
  end
end
