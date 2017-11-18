import { Record } from 'immutable'
import { parseAndFormatDate } from 'utils/dt'

const remoteData = {
  id: null,
  name: '',
  color: null,
  description: null,
  amount: '1',
  cycle: 'monthly',
  amount_currency: 'GBP',
  amount_currency_symbol: null,
  first_bill_date: null,
  next_bill_date: null,
}

const SubscriptionRecord = Record(remoteData)

class Subscription extends SubscriptionRecord {
  // Extend immutable js Record
  get humanFirstBillDate() {
    return parseAndFormatDate(this.first_bill_date)
  }

  get humanNextBillDate() {
    return parseAndFormatDate(this.next_bill_date)
  }
}

export function parseSubscription(remoteData) {
  return new Subscription(remoteData)
}

export default Subscription
