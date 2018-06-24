import api from 'data/api'

const GET_SUBSCRIPTIONS_SUMMARY = 'GET_SUBSCRIPTIONS_SUMMARY'
const GET_SUBSCRIPTIONS_SUMMARY_STARTED = 'GET_SUBSCRIPTIONS_SUMMARY_STARTED'
const GET_SUBSCRIPTIONS_SUMMARY_SUCCESS = 'GET_SUBSCRIPTIONS_SUMMARY_SUCCESS'
const GET_SUBSCRIPTIONS_SUMMARY_FAILURE = 'GET_SUBSCRIPTIONS_SUMMARY_FAILURE'

function handleGetStarted(dispatch) {
  dispatch({ type: GET_SUBSCRIPTIONS_SUMMARY_STARTED })
}

function handleGetSuccess(dispatch, response) {
  const { data, meta } = response.data

  dispatch({ type: GET_SUBSCRIPTIONS_SUMMARY_SUCCESS, data, meta })
}

function handleGetFailure(dispatch, error) {
  dispatch({ type: GET_SUBSCRIPTIONS_SUMMARY_FAILURE, error })
}

const getSubscriptionsSummary = params =>
  (dispatch) => {
    handleGetStarted(dispatch)

    api.getSubscriptionsSummary(params)
      .then(response => handleGetSuccess(dispatch, response))
      .catch(error => handleGetFailure(dispatch, error))
  }

export default getSubscriptionsSummary

export {
  GET_SUBSCRIPTIONS_SUMMARY,
  GET_SUBSCRIPTIONS_SUMMARY_STARTED,
  GET_SUBSCRIPTIONS_SUMMARY_SUCCESS,
  GET_SUBSCRIPTIONS_SUMMARY_FAILURE,
}
