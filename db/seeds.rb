# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

AdminUser.create!(email: "admin@example.com",
                  password: "password",
                  password_confirmation: "password") if Rails.env.development?

SalesRep.create!(code: "000",
                 name: "Default Rep",
                 comm_type: "O",
                 disabled: false,
                 period1: 100, period2: 100, period3: 100, period4: 100, period5: 100,
                 goal1: 5, goal2: 5, goal3: 5, goal4: 5, goal5: 5, goal6: 5, goal7: 5, goal8: 5, goal9: 5, goal10: 5,
                 comm1: 5, comm2: 5, comm3: 5, comm4: 5, comm5: 5, comm6: 5, comm7: 5, comm8: 5, comm9: 5, comm10: 5)
